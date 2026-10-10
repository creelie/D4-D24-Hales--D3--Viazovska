// Counts the vectors of small norm in a lattice given by integer generator rows.
// The lattice is span_Z(rows) / sqrt(scale); norms are computed exactly in integers.
// Fincke-Pohst enumeration on the integer Gram matrix after an LLL reduction of the basis.
// Usage: shortvectors <rows-file> <scale> <max-norm>
// Prints the number of nonzero vectors of each norm up to max-norm.
#include <cmath>
#include <cstdlib>
#include <functional>
#include <cstdint>
#include <cstdio>
#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <vector>
using namespace std;
typedef long long ll;
typedef vector<vector<ll>> Mat;

static Mat read_rows(const char* path) {
  ifstream in(path);
  Mat m;
  string line;
  while (getline(in, line)) {
    istringstream s(line);
    vector<ll> r;
    ll x;
    while (s >> x) r.push_back(x);
    if (!r.empty()) m.push_back(r);
  }
  return m;
}

static ll dot(const vector<ll>& a, const vector<ll>& b) {
  ll s = 0;
  for (size_t i = 0; i < a.size(); ++i) s += a[i] * b[i];
  return s;
}

// Textbook LLL (delta = 0.99) on integer vectors, Gram-Schmidt in long double.
static void lll(Mat& b) {
  int n = b.size();
  vector<vector<long double>> mu(n, vector<long double>(n));
  vector<long double> B(n);
  auto gso = [&]() {
    vector<vector<long double>> bs(n, vector<long double>(b[0].size()));
    for (int i = 0; i < n; ++i) {
      for (size_t k = 0; k < b[i].size(); ++k) bs[i][k] = b[i][k];
      for (int j = 0; j < i; ++j) {
        long double num = 0;
        for (size_t k = 0; k < b[i].size(); ++k) num += b[i][k] * bs[j][k];
        mu[i][j] = num / B[j];
        for (size_t k = 0; k < b[i].size(); ++k) bs[i][k] -= mu[i][j] * bs[j][k];
      }
      B[i] = 0;
      for (size_t k = 0; k < b[i].size(); ++k) B[i] += bs[i][k] * bs[i][k];
    }
  };
  gso();
  int k = 1;
  while (k < n) {
    for (int j = k - 1; j >= 0; --j) {
      ll q = llroundl(mu[k][j]);
      if (q) {
        for (size_t t = 0; t < b[k].size(); ++t) b[k][t] -= q * b[j][t];
        gso();
      }
    }
    if (B[k] >= (0.99L - mu[k][k - 1] * mu[k][k - 1]) * B[k - 1]) {
      ++k;
    } else {
      swap(b[k], b[k - 1]);
      gso();
      k = max(k - 1, 1);
    }
  }
}

int main(int argc, char** argv) {
  if (argc != 4) {
    fprintf(stderr, "usage: %s rows scale max-norm\n", argv[0]);
    return 2;
  }
  Mat b = read_rows(argv[1]);
  ll scale = atoll(argv[2]), maxnorm = atoll(argv[3]);
  int n = b.size();
  // determinant check before reduction is done by the Python and Julia programs
  lll(b);
  // integer Gram matrix of the reduced basis (entries are scale * inner products)
  vector<vector<ll>> G(n, vector<ll>(n));
  for (int i = 0; i < n; ++i)
    for (int j = 0; j < n; ++j) G[i][j] = dot(b[i], b[j]);
  // Cholesky-type decomposition q_ii, q_ij for Fincke-Pohst, in long double
  vector<vector<long double>> q(n, vector<long double>(n, 0));
  for (int i = 0; i < n; ++i)
    for (int j = 0; j < n; ++j) q[i][j] = G[i][j];
  for (int i = 0; i < n; ++i) {
    for (int j = i + 1; j < n; ++j) {
      q[j][i] = q[i][j];
      q[i][j] = q[i][j] / q[i][i];
    }
    for (int k = i + 1; k < n; ++k)
      for (int l = k; l < n; ++l) q[k][l] -= q[k][i] * q[i][l];
  }
  long double C = (long double)(scale * maxnorm) + 1e-6L;
  vector<ll> x(n, 0);
  vector<long double> T(n), U(n);
  map<ll, ll> count;
  ll nodes = 0;
  // recursive enumeration from the last coordinate down
  function<void(int, long double)> rec = [&](int i, long double rem) {
    long double c = 0;
    for (int j = i + 1; j < n; ++j) c += q[i][j] * x[j];
    long double r = sqrtl(rem / q[i][i]);
    ll lo = (ll)ceill(-c - r - 1e-9L), hi = (ll)floorl(-c + r + 1e-9L);
    for (ll v = lo; v <= hi; ++v) {
      ++nodes;
      x[i] = v;
      long double t = q[i][i] * (v + c) * (v + c);
      if (t > rem + 1e-6L) continue;
      if (i == 0) {
        bool zero = true;
        for (ll y : x) if (y) { zero = false; break; }
        if (zero) continue;
        // exact norm in integers
        ll s = 0;
        for (int a = 0; a < n; ++a)
          for (int bb = 0; bb < n; ++bb) s += x[a] * G[a][bb] * x[bb];
        if (s <= scale * maxnorm) {
          if (s % scale) { printf("non-integral norm %lld/%lld\n", s, scale); }
          count[s]++;
        }
      } else {
        rec(i - 1, rem - t);
      }
    }
    x[i] = 0;
  };
  rec(n - 1, C);
  printf("dimension %d, enumeration nodes %lld\n", n, nodes);
  for (auto& kv : count)
    printf("norm %lld/%lld : %lld vectors\n", kv.first, scale, kv.second);
  return 0;
}
