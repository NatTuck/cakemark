

int
ipow(int xx, int kk)
{
    int yy = 1;

    for (int ii = 0; ii < kk; ++ii)
        yy *= xx;

    return yy;
}


