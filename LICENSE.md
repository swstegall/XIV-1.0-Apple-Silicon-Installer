# MIT License

Copyright (c) 2026 Samuel Stegall

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

## Note on third-party components

This installer downloads and invokes — but does not redistribute in
source form — components maintained by upstream projects, each under
its own license:

- **Sikarugir wrapper Frameworks** —
  <https://github.com/Sikarugir-App>. The wrapper template and bundled
  dylibs (libinotify, MoltenVK, etc.) are the copyright of their
  respective authors and are governed by the license shipped with the
  Sikarugir project.
- **CrossOver Wine engine (`WS12WineCX24.0.7_7`)** — built by
  CodeWeavers from the upstream [Wine](https://www.winehq.org/)
  project. Wine itself is LGPL-2.1-or-later; CrossOver's repackaging
  terms apply to the specific binary bundle.
- **FINAL FANTASY XIV 1.0 client** — © SQUARE ENIX CO., LTD. Not
  distributed by this installer; you must supply your own retail
  install disc or ISO.

The MIT license above covers only the installer script
(`install.sh`) and the documentation in this repository.
