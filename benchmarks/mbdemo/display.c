
#include "display.h"

Display*
display_create(int width, int height)
{
    Display* disp = GC_malloc(sizeof(Display));
    disp->width = width;
    disp->height = height;

    SDL_Init(SDL_INIT_VIDEO);

    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

    disp->window = SDL_CreateWindow("Mandelbrot Demo", SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_OPENGL);

    disp->renderer = SDL_CreateRenderer(disp->window, -1, SDL_RENDERER_ACCELERATED);
    
    disp->texture = SDL_CreateTexture(disp->renderer, SDL_PIXELFORMAT_ARGB8888, 
            SDL_TEXTUREACCESS_STREAMING, width, height);

   return disp;
}

void
display_show(Display* disp, uint32_t* image)
{
    int pitch;
    void* pixels;

    SDL_LockTexture(disp->texture, NULL, &pixels, &pitch);

    for (int ii = 0; ii < disp->height; ++ii) {
        uint32_t *row = image + disp->width * ii;

        for (int jj = 0; jj < disp->width; ++jj) {
            uint8_t* pos = pixels + (pitch * ii) + 4 * jj;
            uint32_t* pp = (uint32_t*)pos;
            *pp = *(row + jj);
        }
    }

    SDL_UnlockTexture(disp->texture);

    SDL_RenderClear(disp->renderer);
    SDL_RenderCopy(disp->renderer, disp->texture, NULL, NULL);
    SDL_RenderPresent(disp->renderer);
    SDL_GL_SwapWindow(disp->window);

    SDL_Event event;
    SDL_PollEvent(&event);

    switch (event.type) {
        case SDL_KEYDOWN:
        case SDL_QUIT:
            SDL_Quit();
            exit(0);
    }
}

void 
display_wait(Display* disp, int delay)
{
    SDL_Delay(delay);
}
 
