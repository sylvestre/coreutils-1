#!/bin/sh
# Ensure groups lists the real group ID when it differs from the effective one

# Copyright (C) 2026 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

. "${srcdir=.}/tests/init.sh"; path_prepend_ ./src
print_ver_ groups id
require_root_
require_perl_

rgid=$(id -g) || framework_failure_
egid=$NON_ROOT_GID
test "$rgid" != "$egid" || skip_ "real GID equals $NON_ROOT_GID"

# Keep the real GID, set the effective GID and clear the supplementary groups.
run_egid() { $PERL -e '$) = "$ARGV[0] $ARGV[0]"; shift; exec @ARGV or die' \
               -- "$egid" "$@"; }
run_egid true || skip_ 'unable to set the effective GID'

echo "$rgid $egid" > exp || framework_failure_
run_egid env PATH="$PATH" id -G > out || fail=1
compare exp out || fail=1

run_egid env PATH="$PATH" id -Gn > exp || fail=1
run_egid env PATH="$PATH" groups > out || fail=1
compare exp out || fail=1

Exit $fail
