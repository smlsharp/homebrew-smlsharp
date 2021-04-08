class Smlsharp < Formula
  desc "Standard ML compiler with practical extensions"
  homepage "https://smlsharp.github.io/"
  url "https://github.com/smlsharp/smlsharp/releases/download/v4.0.0/smlsharp-4.0.0.tar.gz"
  sha256 "0b44fb1f369f7cfced197c68f0d3102e940dbe5288adc3bdf618a5a3ec3165db"
  version "4.0.0"
  license "MIT"
  revision 1

  bottle do
    root_url "https://github.com/smlsharp/repos/raw/main/homebrew"
    sha256 big_sur: "39998a174c53d856b267e531645c0dc81337991af181e60efe4be6a4e253b6e3"
  end

  depends_on "llvm@11"
  depends_on "massivethreads"
  depends_on "gmp"
  depends_on "xz" => :build

  def install
    opt_llvm = Formula["llvm@11"].opt_prefix
    system "./configure", "--prefix=#{prefix}", "--with-llvm=#{opt_llvm}"
    system "make", "stage"
    system "make", "all"
    system "make", "install"
  end

  test do
    assert_match "val it = 0xC : word", shell_output("echo '0w12;' | smlsharp")
  end
end
