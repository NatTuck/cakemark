
int get_global_id(int);

kernel
void
get_ids(global int* ids)
{
    int id = get_global_id(0);
    ids[id] = id;
}
