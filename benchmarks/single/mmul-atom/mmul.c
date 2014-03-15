void   /* square matrixes, C = A * B */
mmul(double* C, double* A, double* B, int nn)
{
    for (int ii = 0; ii < nn; ++ii) {
        for (int jj = 0; jj < nn; ++jj) {
            double sum = 0.0;

            for (int kk = 0; kk < nn; ++kk) {
                sum += A[nn * ii + kk] * B[nn * kk + jj];
            }

            C[nn * ii + jj] = sum;
        }
    }
}
