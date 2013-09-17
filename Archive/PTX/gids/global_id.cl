
__kernel void global_id(__global int * out)
{
  unsigned id = get_global_id(0);
  out[id] = id;
}

