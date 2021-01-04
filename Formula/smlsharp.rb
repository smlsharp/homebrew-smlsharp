class Smlsharp < Formula
  desc "Standard ML compiler with practical extensions"
  homepage "http://www.pllab.riec.tohoku.ac.jp/smlsharp/"
  url "https://www.pllab.riec.tohoku.ac.jp/smlsharp/download/smlsharp-3.7.0.tar.gz"
  sha256 "224a8df8dcc9ad717cef79be846159fa918a1030b8fde5476b250f96184d89e7"
  version "3.7.0"
  license "BSD-3-Clause"

  bottle do
        root_url "https://www.pllab.riec.tohoku.ac.jp/smlsharp/download/homebrew-bottles"
    sha256 "7a8a66851af423ad2da1c405a799e9994f8c9ba3d3d543bbc177ed0b81869536" => :big_sur
  end

  depends_on "llvm@9"
  depends_on "massivethreads"
  depends_on "gmp"
  depends_on "xz" => :build

  def install
    opt_llvm = Formula["llvm@9"].opt_prefix
    opt_llvm_bin = Formula["llvm@9"].opt_bin
    system "./configure", "--prefix=#{prefix}", "--with-llvm=#{opt_llvm}"
    system "make", "stage"
    system "make", "all"
    inreplace "src/config.mk" do |s|
      s.sub! /^LLC =.*$/, "LLC = #{opt_llvm_bin}/llc"
      s.sub! /^OPT =.*$/, "OPT = #{opt_llvm_bin}/opt"
      s.sub! /^LLVM_AS =.*$/, "LLVM_AS = #{opt_llvm_bin}/llvm-as"
      s.sub! /^LLVM_DIS =.*$/, "LLVM_DIS = #{opt_llvm_bin}/llvm-dis"
    end
    system "make", "-t"
    system "make", "install"
  end

  test do
    assert_match "val it = 0xC : word", shell_output("echo '0w12;' | smlsharp")
  end
end
