use std::path::Path;

/// This module's Error and Result types
mod error {














    use std::error;
    use std::fmt;
    use std::io;
    /// Error type for semantic engine module
    #[derive(Debug)]
    pub enum Error { IoError(io::Error), Racer, }
    impl error::Error for Error {
        fn description(&self) -> &str {
            match *self {
                Error::IoError(_) => "io::Error during engine operation",
                Error::Racer => "Internal racer error",
            }
        }
        fn cause(&self) -> Option<&error::Error> {
            match *self {
                Error::IoError(ref err) => Some(err),
                Error::Racer => None,
            }
        }
    }
    impl fmt::Display for Error {
        fn fmt(&self, fmt: &mut fmt::Formatter) -> fmt::Result {
            match *self {
                Error::IoError(ref e) => { write!(fmt , "io::Error({})" , e) }
                Error::Racer => write!(fmt , "Internal racer error"),
            }
        }
    }
    impl From<io::Error> for Error {
        fn from(err: io::Error) -> Error { Error::IoError(err) }
    }
    /// Result type for semantic engine module
    pub type Result<T> = ::std::result::Result<T, Error>;
}
pub use self::error::{Error, Result};
use Config;
/// Provide completions, definitions, and analysis of rust source code
pub trait SemanticEngine: Send + Sync {
    /// Perform any necessary initialization.
    ///
    /// Only needs to be called once when an engine is created.
    fn initialize(&self, config: &Config)
    -> Result<()>;
    /// Find the definition for the item under the cursor
    fn find_definition(&self, context: &Context)
    -> Result<Option<Definition>>;
    /// Get a list of completions for the item under the cursor
    fn list_completions(&self, context: &Context)
    -> Result<Option<Vec<Completion>>>;
}
/// A possible completion for a location
#[derive(Debug)]
pub struct Completion {
    pub text: String,
    pub context: String,
    pub kind: String,
    pub file_path: String,
    pub position: CursorPosition,
}
/// Source file and type information for a found definition
#[derive(Debug)]
pub struct Definition {
    pub position: CursorPosition,
    pub text: String,
    pub text_context: String,
    pub dtype: String,
    pub file_path: String,
    pub docs: String,
}
/// Context for a given operation.
///
/// All operations require a buffer holding the contents of a file, the file's absolute path, and a
/// cursor position to fully specify the request. This object holds all of those items.
#[derive(Debug)]
pub struct Context {
    pub buffers: Vec<Buffer>,
    pub query_cursor: CursorPosition,
    pub query_file: String,
}
impl Context {
    pub fn new<T>(buffers: Vec<Buffer>, position: CursorPosition,
                  file_path: T) -> Context where T: Into<String> {
        Context{buffers: buffers,
                query_cursor: position,
                query_file: file_path.into(),}
    }
    pub fn query_path<'a>(&'a self) -> &'a Path {
        &Path::new(&self.query_file[..])
    }
}
/// Position of the cursor in a text file
///
/// Similar to a point, it has two coordinates `line` and `col`.
#[derive(Clone, Copy, Debug)]
pub struct CursorPosition {
    pub line: usize,
    pub col: usize,
}
impl Into<::racer::Location> for CursorPosition {
    fn into(self) -> ::racer::Location {
        ::racer::Location::Coords(::racer::Coordinate{line: self.line,
                                                      column: self.col,})
    }
}
pub mod racer {
    //! SemanticEngine implementation for [the racer library](https://github.com/phildawes/racer)
    //!
    use engine::{SemanticEngine, Definition, Context, CursorPosition,
                 Completion};
    use racer::{self, Session, FileCache, Match, Coordinate};
    use std::sync::Mutex;
    use regex::Regex;
    pub struct Racer {
        cache: Mutex<FileCache>,
    }
    impl Racer {
        pub fn new() -> Racer {
            Racer{cache: Mutex::new(FileCache::default()),}
        }
    }
    unsafe impl Sync for Racer { }
    unsafe impl Send for Racer { }
    use Config;
    use super::Result;
    impl SemanticEngine for Racer {
        fn initialize(&self, config: &Config) -> Result<()> {
            if let Some(ref src_path) = config.rust_src_path {
                ::std::env::set_var("RUST_SRC_PATH", src_path);
            }
            Ok(())
        }
        fn find_definition(&self, ctx: &Context)
         -> Result<Option<Definition>> {
            let cache =
                match self.cache.lock() {
                    Ok(guard) => guard,
                    Err(poisoned) => poisoned.into_inner(),
                };
            let session = Session::new(&cache);
            for buffer in &ctx.buffers {
                session.cache_file_contents(buffer.path(), &*buffer.contents)
            }
            Ok(racer::find_definition(ctx.query_path(), ctx.query_cursor,
                                      &session).and_then(|m|
                                                             {
                                                                 m.coords.map(|Coordinate {
                                                                                   line,
                                                                                   column: col
                                                                                   }|
                                                                                  {
                                                                                      Definition{position:
                                                                                                     CursorPosition{line:
                                                                                                                        line,
                                                                                                                    col:
                                                                                                                        col,},
                                                                                                 dtype:
                                                                                                     format!("{:?}"
                                                                                                             ,
                                                                                                             m
                                                                                                             .
                                                                                                             mtype),
                                                                                                 file_path:
                                                                                                     m.filepath.to_str().unwrap().to_string(),
                                                                                                 text:
                                                                                                     m.matchstr.clone(),
                                                                                                 text_context:
                                                                                                     m.contextstr.clone(),
                                                                                                 docs:
                                                                                                     m.docs.clone(),}
                                                                                  })
                                                             }))
        }
        fn list_completions(&self, ctx: &Context)
         -> Result<Option<Vec<Completion>>> {
            let cache =
                match self.cache.lock() {
                    Ok(guard) => guard,
                    Err(poisoned) => poisoned.into_inner(),
                };
            let session = Session::new(&cache);
            for buffer in &ctx.buffers {
                session.cache_file_contents(buffer.path(), &*buffer.contents)
            }
            let completions =
                racer::complete_from_file(ctx.query_path(), ctx.query_cursor,
                                          &session).filter_map(|Match {
                                                                    matchstr,
                                                                    contextstr,
                                                                    mtype,
                                                                    filepath,
                                                                    coords, ..
                                                                    }|
                                                                   {
                                                                       coords.map(|Coordinate {
                                                                                       line,
                                                                                       column: col
                                                                                       }|
                                                                                      {
                                                                                          Completion{position:
                                                                                                         CursorPosition{line:
                                                                                                                            line,
                                                                                                                        col:
                                                                                                                            col,},
                                                                                                     text:
                                                                                                         matchstr,
                                                                                                     context:
                                                                                                         collapse_whitespace(&contextstr),
                                                                                                     kind:
                                                                                                         format!("{:?}"
                                                                                                                 ,
                                                                                                                 mtype),
                                                                                                     file_path:
                                                                                                         filepath.to_str().unwrap().to_string(),}
                                                                                      })
                                                                   }).collect::<Vec<_>>();
            if completions.len() != 0 {
                Ok(Some(completions))
            } else { Ok(None) }
        }
    }
    pub fn collapse_whitespace(text: &str) -> String {
        Regex::new(r"\s+").unwrap().replace_all(text, " ")
    }
    #[cfg(test)]
    mod tests {
        use super::*;
        use engine::{Context, CursorPosition, SemanticEngine, Buffer};
        use util::fs::TmpFile;
        #[test]
        #[allow(unused_variables)]
        fn find_definition() {
            let src2 =
                TmpFile::with_name("src2.rs",
                                   "\n            /// myfn docs\n            pub fn myfn() {}\n            pub fn foo() {}\n            ");
            let src =
                "\n            use src2::*;\n            mod src2;\n            fn main() {\n                myfn();\n            }";
            let buffers =
                vec!(Buffer {
                     contents : src . to_string (  ) , file_path : "src.rs" .
                     to_string (  ) });
            let ctx =
                Context::new(buffers, CursorPosition{line: 5, col: 17,},
                             "src.rs");
            let racer = Racer::new();
            let def = racer.find_definition(&ctx).unwrap().unwrap();
            assert_eq!(def . text , "myfn");
            assert_eq!(def . docs , "myfn docs");
        }
        #[test]
        #[allow(unused_variables)]
        fn find_completion() {
            let src =
                "\n            mod mymod {\n                /// myfn is a thing\n                pub fn myfn<T>(reader: T) where T: ::std::io::Read {}\n            }\n\n            fn main() {\n                mymod::my\n            }";
            let buffers =
                vec!(Buffer {
                     contents : src . to_string (  ) , file_path : "src.rs" .
                     to_string (  ) });
            let ctx =
                Context::new(buffers, CursorPosition{line: 8, col: 25,},
                             "src.rs");
            let racer = Racer::new();
            let completions = racer.list_completions(&ctx).unwrap().unwrap();
            assert_eq!(completions . len (  ) , 1);
            let completion = &completions[0];
            assert_eq!(completion . text , "myfn");
            assert_eq!(completion . position . line , 4);
            assert_eq!(completion . file_path , "src.rs");
        }
        #[test]
        fn find_completion_collapsing_whitespace() {
            let src =
                "\n            struct foo {}\n\n            impl foo {\n              fn format( &self )\n                -> u32 {\n              }\n            }\n\n            fn main() {\n              let x = foo{};\n              x.\n            }";
            let buffers =
                vec!(Buffer {
                     contents : src . to_string (  ) , file_path : "src.rs" .
                     to_string (  ) });
            let ctx =
                Context::new(buffers, CursorPosition{line: 12, col: 16,},
                             "src.rs");
            let racer = Racer::new();
            let completions = racer.list_completions(&ctx).unwrap().unwrap();
            assert_eq!(completions . len (  ) , 1);
            let completion = &completions[0];
            assert_eq!(completion . context , "fn format( &self ) -> u32");
        }
        #[test]
        fn collapse_whitespace_test() {
            assert_eq!(collapse_whitespace ( "foo  foo" ) , "foo foo");
            assert_eq!(collapse_whitespace ( "  " ) , " ");
            assert_eq!(collapse_whitespace ( "\n\t  \n" ) , " ");
            assert_eq!(collapse_whitespace ( "foo\nbar" ) , "foo bar");
            assert_eq!(collapse_whitespace ( "fn foo( &self )\n   -> u32" ) ,
                       "fn foo( &self ) -> u32");
        }
    }
}
pub use self::racer::Racer;
#[allow(non_upper_case_globals, unused_attributes, unused_qualifications)]
const _IMPL_DESERIALIZE_FOR_Buffer: () =
    {
        extern crate serde as _serde;
        #[automatically_derived]
        impl _serde::de::Deserialize for Buffer {
            fn deserialize<__D>(deserializer: &mut __D)
             -> ::std::result::Result<Buffer, __D::Error> where
             __D: _serde::de::Deserializer {
                #[allow(non_camel_case_types)]
                enum __Field { __field0, __field1, __ignore, }
                impl _serde::de::Deserialize for __Field {
                    #[inline]
                    fn deserialize<__D>(deserializer: &mut __D)
                     -> ::std::result::Result<__Field, __D::Error> where
                     __D: _serde::de::Deserializer {
                        struct __FieldVisitor;
                        impl _serde::de::Visitor for __FieldVisitor {
                            type
                            Value
                            =
                            __Field;
                            fn visit_usize<__E>(&mut self, value: usize)
                             -> ::std::result::Result<__Field, __E> where
                             __E: _serde::de::Error {
                                match value {
                                    0usize => { Ok(__Field::__field0) }
                                    1usize => { Ok(__Field::__field1) }
                                    _ => Ok(__Field::__ignore),
                                }
                            }
                            fn visit_str<__E>(&mut self, value: &str)
                             -> ::std::result::Result<__Field, __E> where
                             __E: _serde::de::Error {
                                match value {
                                    "file_path" => { Ok(__Field::__field0) }
                                    "contents" => { Ok(__Field::__field1) }
                                    _ => Ok(__Field::__ignore),
                                }
                            }
                            fn visit_bytes<__E>(&mut self, value: &[u8])
                             -> ::std::result::Result<__Field, __E> where
                             __E: _serde::de::Error {
                                match value {
                                    b"file_path" => { Ok(__Field::__field0) }
                                    b"contents" => { Ok(__Field::__field1) }
                                    _ => Ok(__Field::__ignore),
                                }
                            }
                        }
                        deserializer.deserialize_struct_field(__FieldVisitor)
                    }
                }
                struct __Visitor;
                impl _serde::de::Visitor for __Visitor {
                    type
                    Value
                    =
                    Buffer;
                    #[inline]
                    fn visit_seq<__V>(&mut self, mut visitor: __V)
                     -> ::std::result::Result<Buffer, __V::Error> where
                     __V: _serde::de::SeqVisitor {
                        let __field0 =
                            match try!(visitor . visit :: < String > (  )) {
                                Some(value) => { value }
                                None => {
                                    try!(visitor . end (  ));
                                    return Err(_serde::de::Error::invalid_length(0usize));
                                }
                            };
                        let __field1 =
                            match try!(visitor . visit :: < String > (  )) {
                                Some(value) => { value }
                                None => {
                                    try!(visitor . end (  ));
                                    return Err(_serde::de::Error::invalid_length(1usize));
                                }
                            };
                        try!(visitor . end (  ));
                        Ok(Buffer{file_path: __field0, contents: __field1,})
                    }
                    #[inline]
                    fn visit_map<__V>(&mut self, mut visitor: __V)
                     -> ::std::result::Result<Buffer, __V::Error> where
                     __V: _serde::de::MapVisitor {
                        let mut __field0: Option<String> = None;
                        let mut __field1: Option<String> = None;
                        while let Some(key) =
                                  try!(visitor . visit_key :: < __Field > (
                                       )) {
                            match key {
                                __Field::__field0 => {
                                    if __field0.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("file_path"));
                                    }
                                    __field0 =
                                        Some(try!(visitor . visit_value :: <
                                                  String > (  )));
                                }
                                __Field::__field1 => {
                                    if __field1.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("contents"));
                                    }
                                    __field1 =
                                        Some(try!(visitor . visit_value :: <
                                                  String > (  )));
                                }
                                _ => {
                                    let _ =
                                        try!(visitor . visit_value :: < _serde
                                             :: de :: impls :: IgnoredAny > (
                                             ));
                                }
                            }
                        }
                        try!(visitor . end (  ));
                        let __field0 =
                            match __field0 {
                                Some(__field0) => __field0,
                                None =>
                                try!(visitor . missing_field ( "file_path" )),
                            };
                        let __field1 =
                            match __field1 {
                                Some(__field1) => __field1,
                                None =>
                                try!(visitor . missing_field ( "contents" )),
                            };
                        Ok(Buffer{file_path: __field0, contents: __field1,})
                    }
                }
                const FIELDS: &'static [&'static str] =
                    &["file_path", "contents"];
                deserializer.deserialize_struct("Buffer", FIELDS, __Visitor)
            }
        }
    };
#[derive(Clone, Debug)]
pub struct Buffer {
    pub file_path: String,
    pub contents: String,
}
impl Buffer {
    pub fn path<'a>(&'a self) -> &'a Path { &Path::new(&self.file_path[..]) }
}
