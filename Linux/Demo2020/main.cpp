#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_mixer.h>
#include <Box2D/Box2D.h>
#include <iostream>
#include <string>
#include <ctime>
#include <cmath>

// Bivrost

// The frames per second
const int FRAMES_PER_SECOND = 60;
const int SCREEN_TICKS_PER_FRAME = 1000 / FRAMES_PER_SECOND;

const int SCREEN_WIDTH = 1280;
const int SCREEN_HEIGHT = 1024;

SDL_Window *gWindow = NULL;

SDL_Surface *gScreenSurface = NULL;
SDL_Surface *gBackgroundSurface = NULL;
SDL_Surface *gLogoSurface = NULL;

static std::string background_filename = "background.png";
static std::string logo_filename = "retry-logo.png";

static std::string music_filename = "MRT - Cybernoid II.mp3";

SDL_Surface *LoadAndOptimizePNG(std::string path)
{
	// The final optimized image
	SDL_Surface *optimizedSurface = NULL;

	// Load image at specified path
	SDL_Surface *loadedSurface = IMG_Load( path.c_str() );
	if (loadedSurface == NULL)
	{
		std::cout << "Unable to load image. SDL Error:" << SDL_GetError() << std::endl;
		return NULL;
	}
	optimizedSurface =
		SDL_ConvertSurface(loadedSurface, gScreenSurface->format, 0);
	SDL_FreeSurface(loadedSurface);

	return optimizedSurface;
}

int main()
{
	SDL_Event event;

	clock_t before;
	clock_t difference;

	double counterX = 0.0;
	double counterY = 2.0;
	double counterZ = 1.2;

	int gRunning = true;

	printf("Demo2020\n");

	if (SDL_Init(SDL_INIT_VIDEO) < 0)
	{
		printf(SDL_GetError());
		gRunning = false;
	}

    if (SDL_Init(SDL_INIT_AUDIO) < 0) {
		printf(SDL_GetError());
		gRunning = false;
    }


	gWindow = SDL_CreateWindow("Hello World!", SDL_WINDOWPOS_UNDEFINED,
							   SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH,
							   SCREEN_HEIGHT, SDL_WINDOW_SHOWN);
	if (gWindow == NULL)
	{
		gRunning = false;
	}

	int imgFlags = IMG_INIT_PNG;
	IMG_Init(imgFlags);

	// If NULL get fucked
	gScreenSurface = SDL_GetWindowSurface(gWindow);
	if (gScreenSurface == NULL)
	{
		gRunning = false;
	}

	gBackgroundSurface = LoadAndOptimizePNG(background_filename);
	if (gBackgroundSurface == NULL)
	{
		gRunning = false;
	}

	gLogoSurface = LoadAndOptimizePNG(logo_filename);
	if (gLogoSurface == NULL)
	{
		gRunning = false;
	}

    Mix_OpenAudio(44100, AUDIO_S16SYS, 2, 640);
    Mix_Music *gMusic = Mix_LoadMUS(music_filename.c_str());
    Mix_PlayMusic(gMusic, 1);

	while (gRunning)
	{
		before = clock();
		while (SDL_PollEvent(&event) != 0)
		{
			if (event.type == SDL_QUIT)
			{
				gRunning = false;
			}
			if (event.type == SDL_KEYDOWN)
			{
				if (event.key.keysym.sym == SDLK_ESCAPE)
				{
					gRunning = false;
				}
			}
		}

		counterZ = counterZ + 0.0015;
		if (counterZ > M_PI * 2)
		{
			counterZ = counterZ - M_PI * 2;
		}
		int z = int(256 + 256 * sin( counterZ ));

		SDL_FillRect(gScreenSurface, NULL, SDL_MapRGB(gScreenSurface->format, 0, 0, 0));

		SDL_Rect offset;
		offset.w = SCREEN_WIDTH;
		offset.h = SCREEN_HEIGHT;
		offset.x = z;
		offset.y = 0;

		SDL_Rect target;
		target.w = SCREEN_WIDTH;
		target.h = SCREEN_HEIGHT;
		target.x = 0;
		target.y = 0;
		
		SDL_BlitSurface(gBackgroundSurface, &offset, gScreenSurface, &target);

		counterX = counterX + 0.0018;
		if (counterX > M_PI * 2)
		{
			counterX = counterX - M_PI * 2;
		}

		counterY = counterY + 0.0021;
		if (counterY > M_PI * 2)
		{
			counterY = counterY - M_PI * 2;
		}

		for ( int row =  0;row <= gLogoSurface->h ; row++ ) {
		int x = int(256 * sin(counterX + (double(row)/256)));
		int y = int(256 * sin(counterY + (double(row)/256)));

		SDL_Rect offset;
		offset.w = SCREEN_WIDTH;
		offset.h = 1;
		offset.x = 0;
		offset.y = row;

		SDL_Rect target;
		target.w = SCREEN_WIDTH;
		target.h = 1;
		target.x = 300+x;
		target.y = 500+y;
		
		SDL_BlitSurface(gLogoSurface, &offset, gScreenSurface, &target);
		}

		SDL_UpdateWindowSurface(gWindow);

		// If frame finished early
		difference = clock() - before;
		if (difference < SCREEN_TICKS_PER_FRAME)
		{
			// Wait remaining time
			SDL_Delay(SCREEN_TICKS_PER_FRAME - difference);
		}
	}
    Mix_FreeMusic(gMusic);
    
	// Deallocate surface
	SDL_FreeSurface(gBackgroundSurface);
	gBackgroundSurface = NULL;

	// Destroy window
	SDL_DestroyWindow(gWindow);
	gWindow = NULL;

	SDL_Quit();
	return 0;
}
