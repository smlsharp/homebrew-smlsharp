class Smlsharp < Formula
  desc "Standard ML compiler with practical extensions"
  homepage "https://smlsharp.github.io/"
  url "https://github.com/smlsharp/smlsharp/releases/download/v4.2.0/smlsharp-4.2.0.tar.gz"
  sha256 "931fb54762c30ab018c804e669d696522cfabafe0a6f85cadefecee1eff710b7"
  version "4.2.0"
  license "MIT"

  depends_on "llvm@18"
  depends_on "massivethreads"
  depends_on "gmp"
  depends_on "xz" => :build
  env :std

  def install
    opt_llvm = Formula["llvm@18"].opt_prefix.sub(/llvm\z/, "llvm@18")
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
