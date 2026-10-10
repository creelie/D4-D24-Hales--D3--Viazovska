/* Independent count of the short vectors of the lattice spanned by E8Matrix.
 * Reads data/e8.txt (rows R = 2 * E8Matrix).  A vector v with doubled coordinates y = 2v
 * lies in the lattice exactly when y = c R for an integer row vector c, that is when
 * y * adj(R) is divisible by det(R).  The program runs over every y in [-4, 4]^8
 * (|v_i| <= 2, enough for norm |v|^2 <= 4), keeps the lattice vectors, and counts them
 * by norm.  Expected: 240 of norm 2 and 2160 of norm 4 (theta series of E8).
 * Usage: e8_box data/e8.txt */
#include <stdio.h>
#include <stdlib.h>

typedef long long ll;
static ll R[8][8], adj[8][8], detR;

static ll det_n(ll m[8][8], int n) {           /* Bareiss fraction-free determinant */
  ll a[8][8], prev = 1, sign = 1;
  for (int i = 0; i < n; i++) for (int j = 0; j < n; j++) a[i][j] = m[i][j];
  for (int k = 0; k < n - 1; k++) {
    if (a[k][k] == 0) {
      int p = k + 1;
      while (p < n && a[p][k] == 0) p++;
      if (p == n) return 0;
      for (int j = 0; j < n; j++) { ll t = a[k][j]; a[k][j] = a[p][j]; a[p][j] = t; }
      sign = -sign;
    }
    for (int i = k + 1; i < n; i++)
      for (int j = k + 1; j < n; j++) a[i][j] = (a[i][j] * a[k][k] - a[i][k] * a[k][j]) / prev;
    prev = a[k][k];
  }
  return sign * a[n - 1][n - 1];
}

int main(int argc, char **argv) {
  FILE *f = fopen(argc > 1 ? argv[1] : "data/e8.txt", "r");
  if (!f) { perror("open"); return 2; }
  for (int i = 0; i < 8; i++) for (int j = 0; j < 8; j++) if (fscanf(f, "%lld", &R[i][j]) != 1) return 2;
  fclose(f);
  detR = det_n(R, 8);
  /* adjugate: adj[j][i] = (-1)^(i+j) * minor(i, j) */
  for (int i = 0; i < 8; i++) for (int j = 0; j < 8; j++) {
    ll m[8][8]; int r = 0;
    for (int a = 0; a < 8; a++) { if (a == i) continue; int c = 0;
      for (int b = 0; b < 8; b++) { if (b == j) continue; m[r][c++] = R[a][b]; } r++; }
    adj[j][i] = ((i + j) % 2 ? -1 : 1) * det_n(m, 7);
  }
  printf("det(2 * E8Matrix) = %lld (expected 2^8 = 256)\n", detR);
  ll count[17] = {0};
  int y[8];
  for (long idx = 0; idx < 43046721L; idx++) {   /* 9^8 points */
    long t = idx; int n2 = 0;
    for (int k = 0; k < 8; k++) { y[k] = (int)(t % 9) - 4; t /= 9; n2 += y[k] * y[k]; }
    if (n2 == 0 || n2 > 16) continue;             /* |v|^2 = n2 / 4 <= 4 */
    int member = 1;
    for (int j = 0; j < 8 && member; j++) {       /* c_j = (y * adj)_j / det */
      ll s = 0;
      for (int k = 0; k < 8; k++) s += (ll)y[k] * adj[k][j];
      if (s % detR) member = 0;
    }
    if (member) count[n2]++;
  }
  int ok = detR == 256 || detR == -256;
  for (int n2 = 1; n2 <= 16; n2++)
    if (count[n2]) printf("norm %d/4 : %lld vectors\n", n2, count[n2]);
  ok = ok && count[8] == 240 && count[16] == 2160;
  for (int n2 = 1; n2 < 8; n2++) ok = ok && count[n2] == 0;
  printf("%s\n", ok ? "PASS: 240 roots, 2160 vectors of norm 4, nothing shorter" : "FAIL");
  return ok ? 0 : 1;
}
