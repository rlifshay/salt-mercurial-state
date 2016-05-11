{% set version = '3.8.1' %}
mercurial:
  archive.extracted:
    - name: /tmp
    - source:
      - salt://mercurial/store/mercurial-{{version}}.tar.gz
      - http://mercurial.selenic.com/release/mercurial-{{version}}.tar.gz
    - source_hash: sha1=a77ddd9640600c8901d0a870f525a660fa6251fa
    - archive_format: tar
    - if_missing: /tmp/mercurial-{{version}}
    - unless:
      - test -f /usr/local/bin/hg
      - '[ "$(hg --version | head -n 1 | grep -o "version [0-9.]\+" | cut -d " " -f 2)" = "{{version}}" ]'
  pkg.installed:
    - name: mercurial-dependencies
    - pkgs:
      - python-dev
      - python-docutils
  cmd.run:
    - name: make install
    - cwd: /tmp/mercurial-{{version}}
    - unless:
      - test -f /usr/local/bin/hg
      - '[ "$(hg --version | head -n 1 | grep -o "version [0-9.]\+" | cut -d " " -f 2)" = "{{version}}" ]'
    - require:
      - archive: mercurial
      - pkg: mercurial-dependencies
  file.copy:
    - name: /usr/local/bin/hg-ssh
    - source: /tmp/mercurial-{{version}}/contrib/hg-ssh
    - force: true
    - makedirs: true
    - mode: 755
    - require:
      - archive: mercurial
      - cmd: mercurial
    - onchanges:
      - archive: mercurial
      - cmd: mercurial