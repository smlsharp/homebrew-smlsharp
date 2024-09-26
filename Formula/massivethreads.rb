class Massivethreads < Formula
  desc "A lightweight thread library for high productivity languages"
  homepage "https://github.com/massivethreads/massivethreads"
  url "https://github.com/massivethreads/massivethreads/archive/v1.00.tar.gz"
  sha256 "85b83ff096e2984c725faa4814a9c5e77c143198660ec60118b897afdfd05f98"
  version "1.00"
  revision 1
  license "BSD-2-Clause"

  option "with-dr", "Install DAG recorder"
  option "with-dl", "Install libmyth-dl"
  depends_on "autoconf@2.69" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "llvm@15" => :build
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

  patch :DATA

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
    system "./configure",
           "--prefix=#{prefix}",
           "CC=#{Formula["llvm@15"].bin/"clang"}"
    system "make"
    system "make", "-C", "tests", "build"
    ENV.delete "MAKEFLAGS"
    system "make", "check"
    system "make", "install"
    Pathname.glob(prefix/"lib/*.la") { |x| x.rmtree }
    (prefix/"lib/libmyth-dl.a").rmtree

    unless build.with? "dl" then
      Pathname.glob(prefix/"lib/libmyth-dl.*") { |x| x.rmtree }
    end

    if build.with? "dr" then
      inreplace bin/"drview", "#!/usr/bin/python", "#!#{libexec}/bin/python"
    else
      (prefix/"bin").rmtree
      (prefix/"include/dag_recorder.h").rmtree
      (prefix/"include/dag_recorder_impl.h").rmtree
      (prefix/"include/dag_recorder_inl.h").rmtree
      (prefix/"include/papi_counters.h").rmtree
      Pathname.glob(prefix/"lib/libdr.*") { |x| x.rmtree }
    end
  end
end

__END__
diff --git a/tests/Makefile.am b/tests/Makefile.am
index 3be159c..322725a 100644
--- a/tests/Makefile.am
+++ b/tests/Makefile.am
@@ -22,11 +22,15 @@ check_PROGRAMS += myth_free
 check_PROGRAMS += myth_calloc
 check_PROGRAMS += myth_posix_memalign
 check_PROGRAMS += myth_valloc
+if BUILD_TEST_MYTH_MEMALIGN
 check_PROGRAMS += myth_memalign
+endif
 if BUILD_TEST_MYTH_ALIGNED_ALLOC
 check_PROGRAMS += myth_aligned_alloc
 endif
+if BUILD_TEST_MYTH_PVALLOC
 check_PROGRAMS += myth_pvalloc
+endif
 check_PROGRAMS += myth_realloc
 check_PROGRAMS += myth_create_0
 check_PROGRAMS += myth_create_1
@@ -94,11 +98,15 @@ check_PROGRAMS += myth_free_ld
 check_PROGRAMS += myth_calloc_ld
 check_PROGRAMS += myth_posix_memalign_ld
 check_PROGRAMS += myth_valloc_ld
+if BUILD_TEST_MYTH_MEMALIGN
 check_PROGRAMS += myth_memalign_ld
+endif
 if BUILD_TEST_MYTH_ALIGNED_ALLOC
 check_PROGRAMS += myth_aligned_alloc_ld
 endif
+if BUILD_TEST_MYTH_PVALLOC
 check_PROGRAMS += myth_pvalloc_ld
+endif
 check_PROGRAMS += myth_realloc_ld
 check_PROGRAMS += myth_create_0_ld
 check_PROGRAMS += myth_create_1_ld
@@ -129,7 +137,9 @@ check_PROGRAMS += measure_latency_ld
 check_PROGRAMS += measure_wakeup_latency_ld
 check_PROGRAMS += measure_malloc_ld
 check_PROGRAMS += measure_thread_specific_ld
+if BUILD_TEST_PTH_BARRIER
 check_PROGRAMS += pth_barrier_ld
+endif
 check_PROGRAMS += pth_cond_broadcast_0_ld
 check_PROGRAMS += pth_cond_broadcast_1_ld
 check_PROGRAMS += pth_cond_signal_ld
@@ -140,7 +150,9 @@ check_PROGRAMS += pth_lock_ld
 check_PROGRAMS += pth_mixlock_ld
 check_PROGRAMS += pth_mutex_initializer_ld
 check_PROGRAMS += pth_trylock_ld
+if BUILD_TEST_PTH_YIELD
 check_PROGRAMS += pth_yield_ld
+endif
 check_PROGRAMS += new_test_ld
 check_PROGRAMS += myth_create_0_cc_ld
 check_PROGRAMS += myth_create_1_cc_ld
@@ -171,7 +183,9 @@ check_PROGRAMS += measure_latency_cc_ld
 check_PROGRAMS += measure_wakeup_latency_cc_ld
 check_PROGRAMS += measure_malloc_cc_ld
 check_PROGRAMS += measure_thread_specific_cc_ld
+if BUILD_TEST_PTH_BARRIER
 check_PROGRAMS += pth_barrier_cc_ld
+endif
 check_PROGRAMS += pth_cond_broadcast_0_cc_ld
 check_PROGRAMS += pth_cond_broadcast_1_cc_ld
 check_PROGRAMS += pth_cond_signal_cc_ld
@@ -182,8 +196,10 @@ check_PROGRAMS += pth_lock_cc_ld
 check_PROGRAMS += pth_mixlock_cc_ld
 check_PROGRAMS += pth_mutex_initializer_cc_ld
 check_PROGRAMS += pth_trylock_cc_ld
+if BUILD_TEST_PTH_YIELD
 check_PROGRAMS += pth_yield_cc_ld
 endif
+endif
 
 if BUILD_MYTH_DL
 check_PROGRAMS += myth_malloc_dl
@@ -191,11 +207,15 @@ check_PROGRAMS += myth_free_dl
 check_PROGRAMS += myth_calloc_dl
 check_PROGRAMS += myth_posix_memalign_dl
 check_PROGRAMS += myth_valloc_dl
+if BUILD_TEST_MYTH_MEMALIGN
 check_PROGRAMS += myth_memalign_dl
+endif
 if BUILD_TEST_MYTH_ALIGNED_ALLOC
 check_PROGRAMS += myth_aligned_alloc_dl
 endif
+if BUILD_TEST_MYTH_PVALLOC
 check_PROGRAMS += myth_pvalloc_dl
+endif
 check_PROGRAMS += myth_realloc_dl
 check_PROGRAMS += myth_create_0_dl
 check_PROGRAMS += myth_create_1_dl
@@ -226,7 +246,9 @@ check_PROGRAMS += measure_latency_dl
 check_PROGRAMS += measure_wakeup_latency_dl
 check_PROGRAMS += measure_malloc_dl
 check_PROGRAMS += measure_thread_specific_dl
+if BUILD_TEST_PTH_BARRIER
 check_PROGRAMS += pth_barrier_dl
+endif
 check_PROGRAMS += pth_cond_broadcast_0_dl
 check_PROGRAMS += pth_cond_broadcast_1_dl
 check_PROGRAMS += pth_cond_signal_dl
@@ -237,7 +259,9 @@ check_PROGRAMS += pth_lock_dl
 check_PROGRAMS += pth_mixlock_dl
 check_PROGRAMS += pth_mutex_initializer_dl
 check_PROGRAMS += pth_trylock_dl
+if BUILD_TEST_PTH_YIELD
 check_PROGRAMS += pth_yield_dl
+endif
 check_PROGRAMS += new_test_dl
 check_PROGRAMS += myth_create_0_cc_dl
 check_PROGRAMS += myth_create_1_cc_dl
@@ -268,7 +292,9 @@ check_PROGRAMS += measure_latency_cc_dl
 check_PROGRAMS += measure_wakeup_latency_cc_dl
 check_PROGRAMS += measure_malloc_cc_dl
 check_PROGRAMS += measure_thread_specific_cc_dl
+if BUILD_TEST_PTH_BARRIER
 check_PROGRAMS += pth_barrier_cc_dl
+endif
 check_PROGRAMS += pth_cond_broadcast_0_cc_dl
 check_PROGRAMS += pth_cond_broadcast_1_cc_dl
 check_PROGRAMS += pth_cond_signal_cc_dl
@@ -279,8 +305,10 @@ check_PROGRAMS += pth_lock_cc_dl
 check_PROGRAMS += pth_mixlock_cc_dl
 check_PROGRAMS += pth_mutex_initializer_cc_dl
 check_PROGRAMS += pth_trylock_cc_dl
+if BUILD_TEST_PTH_YIELD
 check_PROGRAMS += pth_yield_cc_dl
 endif
+endif
 
 myth_malloc_SOURCES = myth_malloc.c
 myth_malloc_CFLAGS = $(common_cflags)
diff --git a/tests/myth_aligned_alloc.c b/tests/myth_aligned_alloc.c
index 84bde17..988cd5d 100644
--- a/tests/myth_aligned_alloc.c
+++ b/tests/myth_aligned_alloc.c
@@ -10,7 +10,7 @@ void * aligned_alloc(size_t al, size_t sz);
 
 int main(int argc, char ** argv) {
   size_t al = (argc > 1 ? atol(argv[1]) : 32);
-  size_t sz = (argc > 2 ? atol(argv[2]) : 35);
+  size_t sz = (argc > 2 ? atol(argv[2]) : 64);
   size_t n  = (argc > 3 ? atol(argv[3]) : 3);
   size_t i;
   for (i = 0; i < n; i++) {
