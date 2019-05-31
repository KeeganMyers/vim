use iron::prelude::*;
use iron::status;
use iron::mime::Mime;

use serde_json::to_string;

use engine::{Completion, Context, CursorPosition, Buffer};
use super::EngineProvider;

/// Given a location, return a list of possible completions
pub fn list(req: &mut Request) -> IronResult<Response> {
    let lcr =
        match req.get::<::bodyparser::Struct<ListCompletionsRequest>>() {
            Ok(Some(s)) => { trace!("parsed ListCompletionsRequest"); s }
            Ok(None) => {
                trace!("failed parsing ListCompletionsRequest");
                return Ok(Response::with(status::BadRequest))
            }
            Err(err) => {
                trace!("error while parsing ListCompletionsRequest");
                return Err(IronError::new(err, status::InternalServerError))
            }
        };

    let mutex = req.get::<::persistent::Write<EngineProvider>>().unwrap();
    let engine = mutex.lock().unwrap_or_else(|e| e.into_inner());
    match engine.list_completions(&lcr.context()) {

        // 200 OK; found the definition
        Ok(Some(completions)) => {
            trace!("got a match");
            let res =
                completions.into_iter().map(|c|
                                                CompletionResponse::from(c)).collect::<Vec<_>>();
            let content_type = "application/json".parse::<Mime>().unwrap();
            Ok(Response::with((content_type, status::Ok,
                               to_string(&res).unwrap())))
        }


        // 204 No Content; Everything went ok, but the definition was not found.
        Ok(None) => {
            trace!("did not find any match");
            Ok(Response::with(status::NoContent))
        }


        // 500 Internal Server Error; Error occurred while searching for the definition
        Err(err) => {
            trace!("encountered an error");
            Err(IronError::new(err, status::InternalServerError))
        }
    }
}




#[allow(non_upper_case_globals, unused_attributes, unused_qualifications)]
const _IMPL_DESERIALIZE_FOR_ListCompletionsRequest: () =
    {
        extern crate serde as _serde;
        #[automatically_derived]
        impl _serde::de::Deserialize for ListCompletionsRequest {
            fn deserialize<__D>(deserializer: &mut __D)
             -> ::std::result::Result<ListCompletionsRequest, __D::Error>
             where __D: _serde::de::Deserializer {
                #[allow(non_camel_case_types)]
                enum __Field {
                    __field0,
                    __field1,
                    __field2,
                    __field3,
                    __ignore,
                }
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
                                    2usize => { Ok(__Field::__field2) }
                                    3usize => { Ok(__Field::__field3) }
                                    _ => Ok(__Field::__ignore),
                                }
                            }
                            fn visit_str<__E>(&mut self, value: &str)
                             -> ::std::result::Result<__Field, __E> where
                             __E: _serde::de::Error {
                                match value {
                                    "buffers" => { Ok(__Field::__field0) }
                                    "file_path" => { Ok(__Field::__field1) }
                                    "column" => { Ok(__Field::__field2) }
                                    "line" => { Ok(__Field::__field3) }
                                    _ => Ok(__Field::__ignore),
                                }
                            }
                            fn visit_bytes<__E>(&mut self, value: &[u8])
                             -> ::std::result::Result<__Field, __E> where
                             __E: _serde::de::Error {
                                match value {
                                    b"buffers" => { Ok(__Field::__field0) }
                                    b"file_path" => { Ok(__Field::__field1) }
                                    b"column" => { Ok(__Field::__field2) }
                                    b"line" => { Ok(__Field::__field3) }
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
                    ListCompletionsRequest;
                    #[inline]
                    fn visit_seq<__V>(&mut self, mut visitor: __V)
                     ->
                         ::std::result::Result<ListCompletionsRequest,
                                               __V::Error> where
                     __V: _serde::de::SeqVisitor {
                        let __field0 =
                            match try!(visitor . visit :: < Vec < Buffer > > (
                                        )) {
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
                        let __field2 =
                            match try!(visitor . visit :: < usize > (  )) {
                                Some(value) => { value }
                                None => {
                                    try!(visitor . end (  ));
                                    return Err(_serde::de::Error::invalid_length(2usize));
                                }
                            };
                        let __field3 =
                            match try!(visitor . visit :: < usize > (  )) {
                                Some(value) => { value }
                                None => {
                                    try!(visitor . end (  ));
                                    return Err(_serde::de::Error::invalid_length(3usize));
                                }
                            };
                        try!(visitor . end (  ));
                        Ok(ListCompletionsRequest{buffers: __field0,
                                                  file_path: __field1,
                                                  column: __field2,
                                                  line: __field3,})
                    }
                    #[inline]
                    fn visit_map<__V>(&mut self, mut visitor: __V)
                     ->
                         ::std::result::Result<ListCompletionsRequest,
                                               __V::Error> where
                     __V: _serde::de::MapVisitor {
                        let mut __field0: Option<Vec<Buffer>> = None;
                        let mut __field1: Option<String> = None;
                        let mut __field2: Option<usize> = None;
                        let mut __field3: Option<usize> = None;
                        while let Some(key) =
                                  try!(visitor . visit_key :: < __Field > (
                                       )) {
                            match key {
                                __Field::__field0 => {
                                    if __field0.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("buffers"));
                                    }
                                    __field0 =
                                        Some(try!(visitor . visit_value :: <
                                                  Vec < Buffer > > (  )));
                                }
                                __Field::__field1 => {
                                    if __field1.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("file_path"));
                                    }
                                    __field1 =
                                        Some(try!(visitor . visit_value :: <
                                                  String > (  )));
                                }
                                __Field::__field2 => {
                                    if __field2.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("column"));
                                    }
                                    __field2 =
                                        Some(try!(visitor . visit_value :: <
                                                  usize > (  )));
                                }
                                __Field::__field3 => {
                                    if __field3.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("line"));
                                    }
                                    __field3 =
                                        Some(try!(visitor . visit_value :: <
                                                  usize > (  )));
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
                                try!(visitor . missing_field ( "buffers" )),
                            };
                        let __field1 =
                            match __field1 {
                                Some(__field1) => __field1,
                                None =>
                                try!(visitor . missing_field ( "file_path" )),
                            };
                        let __field2 =
                            match __field2 {
                                Some(__field2) => __field2,
                                None =>
                                try!(visitor . missing_field ( "column" )),
                            };
                        let __field3 =
                            match __field3 {
                                Some(__field3) => __field3,
                                None =>
                                try!(visitor . missing_field ( "line" )),
                            };
                        Ok(ListCompletionsRequest{buffers: __field0,
                                                  file_path: __field1,
                                                  column: __field2,
                                                  line: __field3,})
                    }
                }
                const FIELDS: &'static [&'static str] =
                    &["buffers", "file_path", "column", "line"];
                deserializer.deserialize_struct("ListCompletionsRequest",
                                                FIELDS, __Visitor)
            }
        }
    };
#[derive(Clone, Debug)]
struct ListCompletionsRequest {
    pub buffers: Vec<Buffer>,
    pub file_path: String,
    pub column: usize,
    pub line: usize,
}
impl ListCompletionsRequest {
    pub fn context(self) -> Context {
        let cursor = CursorPosition{line: self.line, col: self.column,};
        Context::new(self.buffers, cursor, self.file_path)
    }
}
#[allow(non_upper_case_globals, unused_attributes, unused_qualifications)]
const _IMPL_SERIALIZE_FOR_CompletionResponse: () =
    {
        extern crate serde as _serde;
        #[automatically_derived]
        impl _serde::ser::Serialize for CompletionResponse {
            fn serialize<__S>(&self, _serializer: &mut __S)
             -> ::std::result::Result<(), __S::Error> where
             __S: _serde::ser::Serializer {
                let mut __serde_state =
                    try!(_serializer . serialize_struct (
                         "CompletionResponse" , 0 + 1 + 1 + 1 + 1 + 1 + 1 ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "text" , & self . text ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "context" , & self . context ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "kind" , & self . kind ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "file_path" , & self . file_path
                     ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "line" , & self . line ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "column" , & self . column ));
                _serializer.serialize_struct_end(__serde_state)
            }
        }
    };
#[derive(Debug)]
struct CompletionResponse {
    text: String,
    context: String,
    kind: String,
    file_path: String,
    line: usize,
    column: usize,
}
impl From<Completion> for CompletionResponse {
    fn from(c: Completion) -> CompletionResponse {
        CompletionResponse{text: c.text,
                           context: c.context,
                           kind: c.kind,
                           file_path: c.file_path,
                           line: c.position.line,
                           column: c.position.col,}
    }
}
