

int
ipow2(int xx, int kk)
{
    int yy = 1;
    int zz = 1;

    for (int ii = 0; ii < kk; ++ii) {
        yy *= xx;
        zz *= xx + 1;
    }

    return yy + zz;
}


