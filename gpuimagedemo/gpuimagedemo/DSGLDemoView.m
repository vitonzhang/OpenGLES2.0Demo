//
//  DSGLDemoView.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-24.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import "DSGLDemoView.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <GPUImage.h>

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

/*
 
 v2       v1
 
 
 v3       v0
 
 */


static const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}}, // v0 Red
    {{1, 1, 0}, {0, 1, 0, 1}},  // v1 Green
    {{-1, 1, 0}, {0, 0, 1, 1}}, // v2 Blue
    {{-1, -1, 0}, {0, 0, 0, 1}} // v3 Black
};


static const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

static NSString * const VertexShaderString = SHADER_STRING
(
 attribute vec4 Position;
 attribute vec4 SourceColor;
 
 varying vec4 DestinationColor;
 void main(void) {
     DestinationColor = SourceColor;
     gl_Position = Position;
 }
 
 );

static NSString * const FragmentShaderString = SHADER_STRING
(
 varying lowp vec4 DestinationColor;
 void main(void) {
     gl_FragColor = DestinationColor;
 }
);


@implementation DSGLDemoView
{
    GLuint mColorRenderBuffer;
    
    GLuint mPositionSlot;
    GLuint mColorSlot;
}

- (void)setupRenderBuffer {
    /*
     RenderBuffer --> Color Buffer.
     */
    
    // Call glGenRenderbuffers to create a new render buffer object.
    glGenRenderbuffers(1, &mColorRenderBuffer);
    
    // Call glBindRenderbuffer to tell OpenGL “whenever I refer to GL_RENDERBUFFER,
    // I really mean mColorRenderBuffer.”
    glBindRenderbuffer(GL_RENDERBUFFER, mColorRenderBuffer);

    // Allocate some storage for the render buffer.
    // renderbufferStorage:fromDrawable:
    // Attaches an EAGLDrawable as storage for the OpenGL ES renderbuffer object bound to <target>
    [mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:mEaglLayer];
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    /*
     RenderBuffer vs. FrameBuffer
     FrameBuffer: 
     A frame buffer is an OpenGL object that contains a render buffer, 
     and some other buffers you’ll learn about later such as a depth buffer, 
     stencil buffer, and accumulation buffer.
     */
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);

    /*
     glFramebufferRenderbuffer()
     It lets you attach the render buffer you created earlier to the frame buffer’s GL_COLOR_ATTACHMENT0 slot.
     */
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, mColorRenderBuffer);
    
}

- (void)renderSquare {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    /**
     Calls glViewport to set the portion of the UIView to use for rendering.
     This sets it to the entire window, but if you wanted a smallar part you could change these values.
     [TODO]: Change the values of width and height.
     */
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    /*
     Calls glVertexAttribPointer to feed the correct values to the two input variables 
     for the vertex shader – the Position and SourceColor attributes.
     Last Parameter: glVertexAttribPointer
     https://www.khronos.org/opengles/sdk/docs/man/xhtml/glVertexAttribPointer.xml
     */
    glVertexAttribPointer(mPositionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(mColorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 3));
    
    /**
     This actually ends up calling your vertex shader for every vertex you pass in, 
     and then the fragment shader on each pixel to display on the screen.
     
     About the final parameter:
     From the documentation, it appears that the final parameter should be a pointer 
     to the indices. But since we’re using VBOs it’s a special case – it will use 
     the indices array we already passed to OpenGL-land in the GL_ELEMENT_ARRAY_BUFFER.
     */
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
    // Displays a renderbuffer’s contents on screen.
    [mContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)render {

    /*
     the range of color is [0.0, 1.0].
     */
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    
    /*
     Call glClear to actually perform the clearing.
     GL_COLOR_BUFFER_BIT. (render/color buffer).
     */
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Displays a renderbuffer’s contents on screen.
    [mContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)compileShader:(NSString *)shaderString withType:(GLenum)shaderType {
    if (!shaderString) {
        NSLog(@"shaderString is nil.");
    }
    
    /*
     Calls glCreateShader to create a OpenGL object to represent the shader.
     */
    GLuint shaderHandle = glCreateShader(shaderType);
    
    /*
     Calls glShaderSource to give OpenGL the source code for this shader.
     */
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    /**
      calls glCompileShader to compile the shader at runtime!
     */
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString * messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"Shader compile failed: %@", messageString);
    }
    
    return shaderHandle;
}

- (void)compileShaders {
    
    GLuint vertexShader = [self compileShader:VertexShaderString
                                     withType:GL_VERTEX_SHADER];
    
    GLuint fragmentShader = [self compileShader:FragmentShaderString
                                       withType:GL_FRAGMENT_SHADER];
    
    // Calls glCreateProgram, glAttachShader, and glLinkProgram to
    // link the vertex and fragment shaders into a complete program.
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(programHandle, sizeof(message), 0, &message[0]);
        NSString * messageString = [NSString stringWithUTF8String:message];
        NSLog(@"%@", messageString);
    }
    
    glUseProgram(programHandle);
    
    //
    mPositionSlot = glGetAttribLocation(programHandle, "Position");
    mColorSlot = glGetAttribLocation(programHandle, "SourceColor");
    
    // calls glEnableVertexAttribArray to enable use of these arrays
    // (they are disabled by default).
    glEnableVertexAttribArray(mPositionSlot);
    glEnableVertexAttribArray(mColorSlot);
    
}

/**
 The best way to send data to OpenGL is through something called Vertex Buffer Objects.
 What's VBO?
 */
- (void)setupVBOs {
    GLuint vertextBuffer;
    glGenBuffers(1, &vertextBuffer);
    
    //
    glBindBuffer(GL_ARRAY_BUFFER, vertextBuffer);
    
    //
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        
        [self compileShaders];
        [self setupVBOs];
        [self renderSquare];
        // [self render];
    }
    
    return self;
}

@end






