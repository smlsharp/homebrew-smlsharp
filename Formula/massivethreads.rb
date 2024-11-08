class Massivethreads < Formula
  desc "A lightweight thread library for high productivity languages"
  homepage "https://github.com/massivethreads/massivethreads"
  url "https://github.com/massivethreads/massivethreads/archive/v1.02.tar.gz"
  sha256 "b2f6320f51cbfbc051226a61baf9323c016c28f033283e269007493afab0123c"
  version "1.02"
  license "BSD-2-Clause"

  bottle do
    root_url "https://smlsharp.github.io/repos/homebrew"
    sha256 cellar: :any, sonoma: "37a63440a9d611782458b4e7aef8e75fcf1d4b32d07eb07c6812a588b885959a"
  end

  option "with-dr", "Install DAG recorder"
  option "with-dl", "Install libmyth-dl"
  depends_on "autoconf@2.69" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  if build.with? "dr" then
    depends_on "freetype"
    depends_on "libpng"
    depends_on "gtk"
    depends_on "pkg-config" => :build
    depends_on "sqlite"
    depends_on "pygtk"
    depends_on "gnuplot" => :optional
    depends_on "graphviz" => :optional
  end

  if build.with? "dr" then
    include Language::Python::Virtualenv
  end

  def install
    if build.with? "dr" then
      venv = virtualenv_create(libexec)
      system libexec/"bin/pip", "install", "-v", "--no-binary", ":all:",
                                "--ignore-installed", "matplotlib"
    end

    system Formula["autoconf@2.69"].bin/"autoreconf", "-fvi"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "-C", "tests", "build"
    ENV.delete "MAKEFLAGS"
    ENV['MYTH_NUM_WORKERS'] = '2'
    system "make", "check"
    system "make", "install"
    Pathname.glob(prefix/"lib/*.la") { |x| rm x }

    unless build.with? "dl" then
      Pathname.glob(prefix/"lib/libmyth-dl.*") { |x| rm x }
    end

    if build.with? "dr" then
      inreplace bin/"drview", "#!/usr/bin/python", "#!#{libexec}/bin/python"
    else
      rm_r(prefix/"bin")
      rm(prefix/"include/dag_recorder.h")
      rm(prefix/"include/dag_recorder_impl.h")
      rm(prefix/"include/dag_recorder_inl.h")
      rm(prefix/"include/papi_counters.h")
      Pathname.glob(prefix/"lib/libdr.*") { |x| rm x }
    end
  end
end
