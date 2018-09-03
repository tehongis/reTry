/*
   GNU GENERAL PUBLIC LICENSE v3
   Copyright (c) 2018 Tero Hongisto [ tero.hongisto at kolumbus.fi ]
 */


// Dainn, Dvalinn, Duneyrr and Durathror

#include <stdio.h>
#include <stdlib.h>

#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>


GLuint VP_handle = 0;


const char VP_source[] =
								"!!ARBvp1.0\n"
								"\n"
								"#Input\n"
								"ATTRIB InPos   = vertex.position;\n"
								"ATTRIB InColor = vertex.color;\n"
								"\n"
								"#Output\n"
								"OUTPUT OutPos = result.position;\n"
								"OUTPUT OutColor = result.color;\n"
								"\n"
								"PARAM MVP[4] = { state.matrix.mvp }; # Modelview Projection Matrix\n"
								"TEMP Temp;\n"
								"\n"
								"# Transform vertex to clip space\n"
								"DP4 Temp.x, MVP[0], InPos;\n"
								"DP4 Temp.y, MVP[1], InPos;\n"
								"DP4 Temp.z, MVP[2], InPos;\n"
								"DP4 Temp.w, MVP[3], InPos;\n"
								"\n"
								"#Output\n"
								"MOV OutPos, Temp;\n"
								"MOV OutColor, InColor;\n"
								"\n"
								"END\n";


void checkGLError( const char hdr[] )
{
								int err = glGetError();
								if( err )
								{
																fprintf(stderr, "ERROR %s: %s\n", hdr, gluErrorString(err));
																exit(1);
								}
}


void initVertexProgram()
{
								int err = 0;

								glGenProgramsARB( 1, &amp; VP_handle );             // Allocate
								checkGLError( "Allocating Vertex Program" );

								glBindProgramARB( GL_VERTEX_PROGRAM_ARB, VP_handle ); // Activate
								checkGLError( "Binding Vertex Program" );

								glProgramStringARB( GL_VERTEX_PROGRAM_ARB,      // Compile
																												GL_PROGRAM_FORMAT_ASCII_ARB,
																												strlen( VP_source ), VP_source );
								if ( glGetError() == GL_INVALID_OPERATION )
								{
																fprintf( stderr, "ERROR Compiling Vertex Program:\n" );

																// Find the error position
																GLint errPos;
																glGetIntegerv( GL_PROGRAM_ERROR_POSITION_ARB, &amp; errPos );

																// Print implementation-dependent program errors and warnings
																const GLubyte *errString = glGetString( GL_PROGRAM_ERROR_STRING_ARB );
																fprintf( stderr, "Error at position: %d\n%s\n", errPos, errString );
																exit(1);
								}
								checkGLError( "Compiling Vertex Program" );
}


void activateVertexProgram()
{
								glBindProgramARB( GL_VERTEX_PROGRAM_ARB, VP_handle );
								checkGLError( "Binding Vertex Program" );

								glEnable( GL_VERTEX_PROGRAM_ARB );
								checkGLError( "Enabling Vertex Program" );
}


void deactivateVertexProgram()
{
								glDisable( GL_VERTEX_PROGRAM_ARB );
								checkGLError( "Disabling Vertex Program" );
}


void reshape(int width, int height)
{
								glViewport(0, 0, width, height);
}


void display()
{
								int err=0;
								glClear(GL_COLOR_BUFFER_BIT);

								glMatrixMode(GL_PROJECTION);
								glLoadIdentity();
								glOrtho(-1,1,-1,1,-1,1);

								glMatrixMode(GL_MODELVIEW);
								glLoadIdentity();

								glRotatef(30.0, 0,0,1);

								glColor4f(1,0,0,1);

								activateVertexProgram();

								glRectf(-.5,-.5,.5,.5);

								deactivateVertexProgram();

								glutSwapBuffers();
								checkGLError( "End of display()" );
}


int main (int argc, char** argv)
{
								printf("Halls Copyright (C) 2018 Tero Hongisto.\n");
								printf("This program comes with ABSOLUTELY NO WARRANTY.\n\n");

								int nrAttributes;

								//glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
								printf("Maximum nr of vertex attributes supported: %d\n",nrAttributes);;

								glutInit(&amp; argc, argv);
								glutInitDisplayMode( GLUT_RGBA | GLUT_DOUBLE | GLUT_MULTISAMPLE);
								glutCreateWindow(argv[0]);

								glutDisplayFunc(display);
								glutReshapeFunc(reshape);

								glutReshapeWindow(400,400);

								printf("GL_RENDERER = %s\n",glGetString(GL_RENDERER));

								glClearColor(0,0,0,0);

								initVertexProgram();

								glutMainLoop();
								return 0;
}
