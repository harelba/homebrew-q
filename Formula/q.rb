class Q < Formula
  desc "Run SQL directly on CSV or TSV files, and on multiple sqlite databases"
  homepage "https://harelba.github.io/q/"
  url "https://github.com/harelba/q/archive/v3.1.6.tar.gz"
  sha256 "e63ba4ae49647f764c5255ad7065d2c614fdf03a2f7349a795de69529701fab8"

  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/harelba/homebrew-q/releases/download/q-3.1.6"
    sha256 cellar: :any_skip_relocation, big_sur:      "b1e6c7b95855725d6a42eaa51cb58bacc2812ad326d4edf78c896a89166a703a"
    sha256 cellar: :any_skip_relocation, catalina:     "d20039ec31851f03e3d4241a7b86973d255b8156199c4298e560631f9c1a919b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ccb323b44c719a1e56b88d224cb02c4ae611ecd620cd8597e903c0cd689752fa"
  end

  depends_on "pyoxidizer" => :build
  depends_on "ronn" => :build
  depends_on xcode: ["12.4", :build]

  # Patch to allow proper ARM builds by using python3.9.
  # Will be removed in the next version since patch is already in the master
  patch :DATA

  def install
    arch_folder = if OS.linux?
      "x86_64-unknown-linux-gnu"
    elsif Hardware::CPU.intel?
      "x86_64-apple-darwin"
    else
      "aarch64-apple-darwin"
    end

    system "pyoxidizer", "build", "--release", "--var", "PYTHON_VERSION", "3.9"
    bin.install "./build/#{arch_folder}/release/install/q"

    system "ronn", "--roff", "--section=1", "doc/USAGE.markdown"
    man1.install "doc/USAGE.1" => "q.1"
  end

  test do
    seq = (1..100).map(&:to_s).join("\n")
    output = pipe_output("#{bin}/q -c 1 'select sum(c1) from -'", seq)
    assert_equal "5050\n", output
  end
end

__END__
diff --git a/pyoxidizer.bzl b/pyoxidizer.bzl
index da79ba2..8a27c4b 100644
--- a/pyoxidizer.bzl
+++ b/pyoxidizer.bzl
@@ -3,11 +3,13 @@
 # https://pyoxidizer.readthedocs.io/en/stable/ for details of this
 # configuration file format.
 
+PYTHON_VERSION = VARS.get("PYTHON_VERSION","3.8")
+
 # Configuration files consist of functions which define build "targets."
 # This function creates a Python executable and installs it in a destination
 # directory.
 def make_exe():
-    dist = default_python_distribution(python_version="3.8")
+    dist = default_python_distribution(python_version=PYTHON_VERSION)
 
     policy = dist.make_python_packaging_policy()
     policy.set_resource_handling_mode("classify")

