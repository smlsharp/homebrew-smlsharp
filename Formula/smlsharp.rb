class Smlsharp < Formula
  desc "Standard ML compiler with practical extensions"
  homepage "https://smlsharp.github.io/"
  url "https://github.com/smlsharp/smlsharp/releases/download/v4.0.0/smlsharp-4.0.0.tar.gz"
  sha256 "0b44fb1f369f7cfced197c68f0d3102e940dbe5288adc3bdf618a5a3ec3165db"
  version "4.0.0"
  license "MIT"
  revision 2

  bottle do
    root_url "https://github.com/smlsharp/repos/raw/main/homebrew"
    sha256 big_sur: "5a71f04d57ac27cece90983cb041a5bdd9ae6aca2612da0bd5137317d1490bd5"
  end

  depends_on "llvm@12"
  depends_on "massivethreads"
  depends_on "gmp"
  depends_on "xz" => :build

  def install
    opt_llvm = Formula["llvm@12"].opt_prefix.sub(/llvm\z/, "llvm@12")
    opt_llvm_bin = opt_llvm/"bin"
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
