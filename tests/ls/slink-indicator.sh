#!/bin/sh
# Indicator style (-F/--file-type/-p) applies to symlink targets in -l,
# and the symlink name itself never gets '@' in long mode.

# Copyright (C) 2026 Free Software Foundation, Inc.
# License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.

. "${srcdir=.}/tests/init.sh";
print_ver_ ls

mkdir dir || framework_failure_
touch reg exe && chmod a+x exe || framework_failure_
mkfifo_or_skip_ fifo
ln -s dir slink-dir
ln -s exe slink-exe
ln -s reg slink-reg
ln -s fifo slink-fifo
ln -s nowhere slink-dangle

pick() { sed -n 's/.* \(slink-[a-z]*\) -> /\1 -> /p' | LC_ALL=C sort; }

ls -lF slink-* > raw || fail=1
pick < raw > out1 || fail=1
printf '%s\n' \
  'slink-dangle -> nowhere' \
  'slink-dir -> dir/' \
  'slink-exe -> exe*' \
  'slink-fifo -> fifo|' \
  'slink-reg -> reg' > exp1
compare exp1 out1 || fail=1

# Symlink name must not be suffixed with '@' in long mode.
grep 'slink-[a-z]*@' raw && fail=1

ls -l --file-type slink-* | pick > out2 || fail=1
sed 's/\*$//' exp1 > exp2
compare exp2 out2 || fail=1

# -lp: slash-only does NOT apply to symlink targets, even dir ones.
ls -lp slink-* | pick > out3 || fail=1
sed 's/[*/|]$//' exp1 > exp3
compare exp3 out3 || fail=1

Exit $fail
