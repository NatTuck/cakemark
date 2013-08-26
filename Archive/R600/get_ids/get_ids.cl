
__kernel
void
get_ids(__global int* ids)
{
    unsigned int id = get_global_id(0);
    ids[id] = id;
}
