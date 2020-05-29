class Smlsharp < Formula
  desc "Standard ML compiler with practical extensions"
  homepage "http://www.pllab.riec.tohoku.ac.jp/smlsharp/"
  url "https://www.pllab.riec.tohoku.ac.jp/smlsharp/download/smlsharp-3.6.0.tar.gz"
  sha256 "83790d5e6b468a08f7fb221f0c2682f4243aaff063c4c43533734e4232e7720b"
  version "3.6.0"

  bottle do
    root_url "https://www.pllab.riec.tohoku.ac.jp/smlsharp/download/homebrew-bottles"
    sha256 "44e170173c88a214825cc1d7f53ab87c377d711c97c479e4bde17e1364304947" => :catalina
  end

  depends_on "llvm"
  depends_on "massivethreads"
  depends_on "gmp"
  depends_on "yajl"
  depends_on "xz" => :build

  def install
    opt_llvm_bin = Formula["llvm"].opt_prefix
    system "./configure", "--prefix=#{prefix}", "--with-llvm=#{opt_llvm_bin}"
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
