# Mac notes

```bash
==> python@3.9
Python has been installed as
/usr/local/bin/python3

Unversioned symlinks `python`, `python-config`, `pip` etc. pointing to
`python3`, `python3-config`, `pip3` etc., respectively, have been installed into
/usr/local/opt/python@3.9/libexec/bin

You can install Python packages with
pip3 install `<package>`
They will install into the site-package directory
/usr/local/lib/python3.9/site-packages

tkinter is no longer included with this formula, but it is available separately:
brew install python-tk@3.9

See: https://docs.brew.sh/Homebrew-and-Python
```

```bash
~/code/grafana ᐅ brew install java
==> Downloading https://ghcr.io/v2/homebrew/core/openjdk/manifests/17.0.1_1
######################################################################## 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/openjdk/blobs/sha256:bcbefe19b5b240fb33b05cdeb0b26e133ed698f8b829b1383a7ad3cb45b871c2
==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sha256:bcbefe19b5b240fb33b05cdeb0b26e133ed698f8b829b1383a7ad3cb45b871c2?se=2021-12-20T06%3A20%3A00Z&sig=6TwtmVJZqUzaDfLpmx2nGq%2Fmp6
######################################################################## 100.0%
==> Pouring openjdk--17.0.1_1.monterey.bottle.tar.gz
==> Caveats
For the system Java wrappers to find this JDK, symlink it with
  sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

openjdk is keg-only, which means it was not symlinked into /usr/local,
because macOS provides similar software and installing this software in
parallel can cause all kinds of trouble.

If you need to have openjdk first in your PATH, run:
  echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"' >> ~/.zshrc

For compilers to find openjdk you may need to set:
  export CPPFLAGS="-I/usr/local/opt/openjdk/include"

==> Summary
🍺  /usr/local/Cellar/openjdk/17.0.1_1: 639 files, 305.2MB
```