#ifndef DISPLAY_H
#define DISPLAY_H

#include <stdint.h>
#include <SDL2/SDL.h>
#include <gc/gc.h>

typedef struct Display {
    int width;
    int height;
    SDL_Window* window;
    SDL_Renderer* renderer;
    SDL_Texture* texture;
} Display;

Display* display_create(int width, int height);
void display_show(Display* disp, uint32_t* image);
void display_wait(Display* disp, int delay);

#endif
