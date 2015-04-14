//
//  DSGLFancyTextureView.m
//  gpuimagedemo
//
//  Created by zhangchong on 15-3-30.
//  Copyright (c) 2015年 vitonzhang. All rights reserved.
//

#import "DSGLFancyTextureView.h"
#import "CC3GLMatrix.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GPUImage.h>

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

/*
static const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, 0}, {1, 0, 0, 1}, {1, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}, {0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}, {0, 0}},
    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, -1}, {1, 0, 0, 1}, {1, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}, {0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}, {0, 0}}
};
*/

#define TEX_COORD_MAX   1

static const Vertex Vertices[] = {
    // Front
    {{1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Back
    {{1, 1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, -1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, -1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 0, 1}, {0, 0}},
    // Left
    {{-1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, 1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 0, 0, 1}, {0, 0}},
    // Right
    {{1, -1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, 1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Top
    {{1, 1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, 0}, {0, 0, 0, 1}, {0, 0}},
    // Bottom
    {{1, -1, -2}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{1, -1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, -1, 0}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 0, 0, 1}, {0, 0}}
};

/*
static const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4
};
*/

static const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    4, 5, 7,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};


static NSString * const VertexShaderString = SHADER_STRING
(
 attribute vec4 Position;
 attribute vec4 SourceColor;
 uniform mat4 Projection;
 uniform mat4 Modelview;
 
 varying vec4 DestinationColor;
 
 attribute vec2 TexCoordIn;
 // Remember that a varying is a value that OpenGL will automatically
 // interpolate for us by the time it gets to the fragment shader.
 varying vec2 TexCoordOut;
 
 void main(void) {
     DestinationColor = SourceColor;
     // Switch Projection and Position. Why is the order like that?
     gl_Position = Projection * Modelview * Position;
     TexCoordOut = TexCoordIn;
     // TexCoordOut = TexCoordIn.yz;
 }
 
 );

static NSString * const FragmentShaderString = SHADER_STRING
(
 varying lowp vec4 DestinationColor;
 
 varying lowp vec2 TexCoordOut;
 uniform sampler2D Texture;
 
 void main(void) {
     gl_FragColor = DestinationColor * texture2D(Texture, TexCoordOut);
 }
 
 );

@implementation DSGLFancyTextureView
{
    GLuint mColorRenderBuffer;
    GLuint mDepthBuffer;
    
    GLuint mPositionSlot;
    GLuint mColorSlot;
    GLuint mProjectionUniform;
    GLuint mModelviewUniform;
    GLuint mFloorTexture;
    GLuint mFishTexture;
    GLuint mTexCoordSlot;
    GLuint mTextureUniform;
    
    
    CADisplayLink * mDisplayLink;
    float mCurrentRotation;
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

- (void)setupDepthBuffer {
    
    //
    glGenRenderbuffers(1, &mDepthBuffer);
    
    //
    glBindRenderbuffer(GL_RENDERBUFFER, mDepthBuffer);
    
    //
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
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
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, mDepthBuffer);
    
}

- (GLuint)setupTexture:(NSString *)fileName {
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height,
                                                       8, width * 4, CGImageGetColorSpace(spriteImage),
                                                       (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    GLuint textureName;
    glGenTextures(1, &textureName);
    glBindTexture(GL_TEXTURE_2D, textureName);
    // GL_LINEAR
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    /*
     Once we’ve sent the image data to OpenGL, we can deallocate the
     pixel buffer – we don’t need it anymore because OpenGL is storing
     the texture in the GPU.
     */
    free(spriteData);
    return textureName;
}

- (void)renderSquare {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    // glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2
                               andRight:2
                              andBottom:-h/2
                                 andTop:h/2
                                andNear:4
                                 andFar:10];
    
    NSLog(@"Projection Matrix: %@", [projection description]);
    glUniformMatrix4fv(mProjectionUniform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelview = [CC3GLMatrix matrix];
    // [modelview populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];
    [modelview populateFromTranslation:CC3VectorMake(0, 0, -7)];
    // [modelview rotateBy:CC3VectorMake(1, mCurrentRotation, 0)];
    [modelview rotateBy:CC3VectorMake(mCurrentRotation, mCurrentRotation, 0)];
    NSLog(@"Modelview Matrix: %@", [modelview description]);
    glUniformMatrix4fv(mModelviewUniform, 1, 0, modelview.glMatrix);
    
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
    glVertexAttribPointer(mTexCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 7));
    
    // we activate the texture unit we want to load our texture into.
    /*
     glActiveTexture()
     https://www.opengl.org/sdk/docs/man/docbook4/xhtml/glActiveTexture.xml
     glActiveTexture selects which texture unit subsequent texture state calls will affect.
     The number of texture units an implementation supports is implementation dependent.
     */
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, mFloorTexture);
    glUniform1i(mTextureUniform, 0);
    
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

- (void)render:(CADisplayLink *)displayLink {
    
    mCurrentRotation += displayLink.duration * 90;
    [self renderSquare];
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
    
    //
    mProjectionUniform = glGetUniformLocation(programHandle, "Projection");
    mModelviewUniform = glGetUniformLocation(programHandle, "Modelview");
    
    mTexCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    glEnableVertexAttribArray(mTexCoordSlot);
    mTextureUniform = glGetUniformLocation(programHandle, "Textture");
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

- (void)setupDisplayLink {
    mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        
        // TODO: Switch the order of the next tow lines.
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        
        [self compileShaders];
        [self setupVBOs];
        // [TODO]: Replace this line A with line B.
        // [self renderSquare];  // A
        [self setupDisplayLink]; // B
        
        // [TODO] Have a try:
        // Delete the resource file: item_powerup_fish.png and tile_floor.png.
        mFishTexture = [self setupTexture:@"item_powerup_fish.png"];
        mFloorTexture = [self setupTexture:@"tile_floor.png"];
    }
    
    return self;
}

- (void)onDisappear {
    [super onDisappear];
    [mDisplayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
@end



