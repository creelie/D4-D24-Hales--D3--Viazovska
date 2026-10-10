#!/usr/bin/env bash
# Static scan of the Lean sources in sphere-packing/ for anything that could let a proof
# bypass the kernel or add assumptions: sorry, admit, new axioms, native_decide and
# Lean.ofReduceBool, implemented_by / extern, unsafe and opaque declarations, kernel
# debugging options, environment-modifying commands.  Comment lines are skipped.
# Usage: verification/scan.sh [path-to-sphere-packing]
set -u
root="${1:-$(dirname "$0")/../sphere-packing}"
files=$(find "$root/SpherePacking" "$root/SpherePacking.lean" -name '*.lean')
nfiles=$(echo "$files" | wc -l)
nlines=$(cat $files | wc -l)
echo "scanning $nfiles Lean files, $nlines lines, under $root"
status=0
check() {
  local label="$1" pattern="$2"
  # strip line comments before matching; block comments are prose and are reported if they match
  local hits
  hits=$(grep -EHn "$pattern" $files | grep -Ev ':[0-9]+:\s*--' || true)
  local n=0
  [ -n "$hits" ] && n=$(echo "$hits" | wc -l)
  printf '%-34s %s\n' "$label" "$n"
  if [ "$n" -gt 0 ]; then echo "$hits" | head -5; status=1; fi
}
check "sorry"                     '(^|[^A-Za-z_.])sorry([^A-Za-z_]|$)'
check "admit (tactic)"            '(^|[;(]|by)\s*admit\s*($|[;)])'
check "axiom declarations"        '^\s*(@\[[^]]*\]\s*)?(private |public |protected |noncomputable )*axiom\s'
check "native_decide"             'native_decide'
check "Lean.ofReduceBool"         'ofReduceBool|ofReduceNat'
check "implemented_by / extern"   'implemented_by|@\[extern'
check "unsafe"                    '(^|\s)unsafe\s'
check "opaque"                    '^\s*(private |public |protected )*opaque\s'
check "debug / skipKernelTC"      'set_option\s+debug|skipKernelTC'
check "run_cmd / run_elab / addDecl" 'run_cmd|run_elab|run_meta|addDecl|modifyEnv'
check "bv_decide (trusts LRAT checker)" 'bv_decide'
# `decide +kernel` is reported but allowed: the kernel itself evaluates the decision
# procedure, so nothing outside the kernel is trusted.
n=$(grep -Ec 'decide\s*\+kernel' $files | awk -F: '{s+=$NF} END {print s}')
printf '%-34s %s (allowed: checked by the kernel)\n' "decide +kernel" "$n"
if [ $status -eq 0 ]; then echo "scan: clean"; else echo "scan: FOUND ITEMS ABOVE"; fi
exit $status
