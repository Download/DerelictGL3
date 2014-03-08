/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software" ) to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.opengl3.internal.common;

private {
    import core.stdc.string;
    import std.string;
    import std.conv;

    import derelict.util.exception;
    import derelict.util.system;
    import derelict.opengl3.internal.platform;
    import derelict.opengl3.internal.types;
    import derelict.opengl3.internal.coreconstants;
    //static if( Derelict_OS_Mac ) import derelict.opengl3.cgl;
    //else static if( Derelict_OS_Posix ) import derelict.opengl3.glx;
}

public {
        void bindGLFunc( alias ctx )( void** ptr, string symName ) {
            auto sym = loadGLFunc!ctx( symName );
            if( !sym )
                throw new SymbolLoadException( "Failed to load OpenGL symbol [" ~ symName ~ "]" );
            *ptr = sym;
        }

        bool isExtSupported( alias ctx )( GLVersion glversion, string name ) {
            // If OpenGL 3+ is loaded, use glGetStringi.
            if( glversion >= GLVersion.GL30 ) {
                auto cstr = name.toStringz(  );
                int count;
                ctx.glGetIntegerv( GL_NUM_EXTENSIONS, &count );
                for( int i=0; i<count; ++i ) {
                    if( strcmp( ctx.glGetStringi( GL_EXTENSIONS, i ), cstr ) == 0 )
                        return true;
                }
                return false;
            }
            // Otherwise use the classic approach.
            else {
                return findEXT(  ctx.glGetString( GL_EXTENSIONS ), name  );
            }
        }

        // Assumes that extname is null-terminated, i.e. a string literal
        bool findEXT( const char *extstr, string extname  ) {
            import core.stdc.string;
            auto res = strstr( extstr, extname.ptr  );
            while( res  ) {
                // It's possible that the extension name is actually a
                // substring of another extension. If not, then the
                // character following the name in the extension string
                // should be a space (or possibly the null character ).
                if( res[ extname.length ] == ' ' || res[ extname.length ] == '\0' )
                    return true;
                res = strstr( res + extname.length, extname.ptr  );
            }

            return false;
        }
}