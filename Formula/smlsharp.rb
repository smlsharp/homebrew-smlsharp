class Smlsharp < Formula
  desc "Standard ML compiler with practical extensions"
  homepage "http://www.pllab.riec.tohoku.ac.jp/smlsharp/"
  url "https://www.pllab.riec.tohoku.ac.jp/smlsharp/download/smlsharp-3.5.0.tar.gz"
  sha256 "0ef9861685b6b02b6ea81e659563f955c48f156b75b92782e769bb25f07b2ad8"
  version "3.5.0"

  bottle do
    root_url "https://www.pllab.riec.tohoku.ac.jp/smlsharp/download/homebrew-bottles"
    sha256 "a3f931b26802b31016d5f512eaf17c39f380fa1e5d389e11b207e628ee0fe86f" => :catalina
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
