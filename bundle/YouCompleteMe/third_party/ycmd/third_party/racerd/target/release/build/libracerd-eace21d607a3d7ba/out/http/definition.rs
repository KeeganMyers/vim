use iron::prelude::*;
use iron::status;
use iron::mime::Mime;

use serde_json::to_string;

use engine::{Definition, Context, CursorPosition, Buffer};
use super::EngineProvider;

/// Given a location, return where the identifier is defined
///
/// Possible responses include
///
/// - `200 OK` the request was successful and a JSON object is returned.
/// - `204 No Content` the request was successful, but no match was found.
/// - `400 Bad Request` the request payload was malformed
/// - `500 Internal Server Error` some unexpected error occurred
pub fn find(req: &mut Request) -> IronResult<Response> {

    // Parse the request. If the request doesn't parse properly, the request is invalid, and a 400
    // BadRequest is returned.
    let fdr =
        match req.get::<::bodyparser::Struct<FindDefinitionRequest>>() {
            Ok(Some(s)) => {
                trace!("definition::find parsed FindDefinitionRequest");
                s
            }
            Ok(None) => {
                trace!("definition::find failed parsing FindDefinitionRequest");
                return Ok(Response::with(status::BadRequest))
            }
            Err(err) => {
                trace!("definition::find received error while parsing FindDefinitionRequest");
                return Err(IronError::new(err, status::InternalServerError))
            }
        };

    let mutex = req.get::<::persistent::Write<EngineProvider>>().unwrap();
    let engine = mutex.lock().unwrap_or_else(|e| e.into_inner());
    match engine.find_definition(&fdr.context()) {

        // 200 OK; found the definition
        Ok(Some(definition)) => {
            trace!("definition::find got a match");
            let res = FindDefinitionResponse::from(definition);
            let content_type = "application/json".parse::<Mime>().unwrap();
            Ok(Response::with((content_type, status::Ok,
                               to_string(&res).unwrap())))
        }


        // 204 No Content; Everything went ok, but the definition was not found.
        Ok(None) => {
            trace!("definition::find did not find a match");
            Ok(Response::with(status::NoContent))
        }


        // 500 Internal Server Error; Error occurred while searching for the definition
        Err(err) => {
            trace!("definition::find encountered an error");
            Err(IronError::new(err, status::InternalServerError))
        }
    }
}

impl From<Definition> for FindDefinitionResponse {
    fn from(def: Definition) -> FindDefinitionResponse {
        FindDefinitionResponse{file_path: def.file_path,
                               column: def.position.col,
                               line: def.position.line,
                               text: def.text,
                               context: def.text_context,
                               kind: def.dtype,
                               docs: def.docs,}
    }
}





#[allow(non_upper_case_globals, unused_attributes, unused_qualifications)]
const _IMPL_DESERIALIZE_FOR_FindDefinitionRequest: () =
    {
        extern crate serde as _serde;
        #[automatically_derived]
        impl _serde::de::Deserialize for FindDefinitionRequest {
            fn deserialize<__D>(deserializer: &mut __D)
             -> ::std::result::Result<FindDefinitionRequest, __D::Error> where
             __D: _serde::de::Deserializer {
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
                    FindDefinitionRequest;
                    #[inline]
                    fn visit_seq<__V>(&mut self, mut visitor: __V)
                     ->
                         ::std::result::Result<FindDefinitionRequest,
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
                        Ok(FindDefinitionRequest{buffers: __field0,
                                                 file_path: __field1,
                                                 column: __field2,
                                                 line: __field3,})
                    }
                    #[inline]
                    fn visit_map<__V>(&mut self, mut visitor: __V)
                     ->
                         ::std::result::Result<FindDefinitionRequest,
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
                        Ok(FindDefinitionRequest{buffers: __field0,
                                                 file_path: __field1,
                                                 column: __field2,
                                                 line: __field3,})
                    }
                }
                const FIELDS: &'static [&'static str] =
                    &["buffers", "file_path", "column", "line"];
                deserializer.deserialize_struct("FindDefinitionRequest",
                                                FIELDS, __Visitor)
            }
        }
    };
#[derive(Clone, Debug)]
struct FindDefinitionRequest {
    pub buffers: Vec<Buffer>,
    pub file_path: String,
    pub column: usize,
    pub line: usize,
}
impl FindDefinitionRequest {
    pub fn context(self) -> Context {
        let cursor = CursorPosition{line: self.line, col: self.column,};
        Context::new(self.buffers, cursor, self.file_path)
    }
}
#[test]
fn find_definition_request_from_json() {
    let s =
        stringify!({
                   "file_path" : "src.rs" , "buffers" : [
                   {
                   "file_path" : "src.rs" , "contents" :
                   "fn foo() {}\nfn bar() {}\nfn main() {\nfoo();\n}" } ] ,
                   "line" : 4 , "column" : 3 });
    let req: FindDefinitionRequest = ::serde_json::from_str(s).unwrap();
    assert_eq!(req . file_path , "src.rs");
    assert_eq!(req . line , 4);
    assert_eq!(req . column , 3);
}
#[allow(non_upper_case_globals, unused_attributes, unused_qualifications)]
const _IMPL_SERIALIZE_FOR_FindDefinitionResponse: () =
    {
        extern crate serde as _serde;
        #[automatically_derived]
        impl _serde::ser::Serialize for FindDefinitionResponse {
            fn serialize<__S>(&self, _serializer: &mut __S)
             -> ::std::result::Result<(), __S::Error> where
             __S: _serde::ser::Serializer {
                let mut __serde_state =
                    try!(_serializer . serialize_struct (
                         "FindDefinitionResponse" , 0 + 1 + 1 + 1 + 1 + 1 + 1
                         + 1 ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "file_path" , & self . file_path
                     ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "column" , & self . column ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "line" , & self . line ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "text" , & self . text ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "context" , & self . context ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "kind" , & self . kind ));
                try!(_serializer . serialize_struct_elt (
                     & mut __serde_state , "docs" , & self . docs ));
                _serializer.serialize_struct_end(__serde_state)
            }
        }
    };
#[allow(non_upper_case_globals, unused_attributes, unused_qualifications)]
const _IMPL_DESERIALIZE_FOR_FindDefinitionResponse: () =
    {
        extern crate serde as _serde;
        #[automatically_derived]
        impl _serde::de::Deserialize for FindDefinitionResponse {
            fn deserialize<__D>(deserializer: &mut __D)
             -> ::std::result::Result<FindDefinitionResponse, __D::Error>
             where __D: _serde::de::Deserializer {
                #[allow(non_camel_case_types)]
                enum __Field {
                    __field0,
                    __field1,
                    __field2,
                    __field3,
                    __field4,
                    __field5,
                    __field6,
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
                                    4usize => { Ok(__Field::__field4) }
                                    5usize => { Ok(__Field::__field5) }
                                    6usize => { Ok(__Field::__field6) }
                                    _ => Ok(__Field::__ignore),
                                }
                            }
                            fn visit_str<__E>(&mut self, value: &str)
                             -> ::std::result::Result<__Field, __E> where
                             __E: _serde::de::Error {
                                match value {
                                    "file_path" => { Ok(__Field::__field0) }
                                    "column" => { Ok(__Field::__field1) }
                                    "line" => { Ok(__Field::__field2) }
                                    "text" => { Ok(__Field::__field3) }
                                    "context" => { Ok(__Field::__field4) }
                                    "kind" => { Ok(__Field::__field5) }
                                    "docs" => { Ok(__Field::__field6) }
                                    _ => Ok(__Field::__ignore),
                                }
                            }
                            fn visit_bytes<__E>(&mut self, value: &[u8])
                             -> ::std::result::Result<__Field, __E> where
                             __E: _serde::de::Error {
                                match value {
                                    b"file_path" => { Ok(__Field::__field0) }
                                    b"column" => { Ok(__Field::__field1) }
                                    b"line" => { Ok(__Field::__field2) }
                                    b"text" => { Ok(__Field::__field3) }
                                    b"context" => { Ok(__Field::__field4) }
                                    b"kind" => { Ok(__Field::__field5) }
                                    b"docs" => { Ok(__Field::__field6) }
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
                    FindDefinitionResponse;
                    #[inline]
                    fn visit_seq<__V>(&mut self, mut visitor: __V)
                     ->
                         ::std::result::Result<FindDefinitionResponse,
                                               __V::Error> where
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
                            match try!(visitor . visit :: < usize > (  )) {
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
                            match try!(visitor . visit :: < String > (  )) {
                                Some(value) => { value }
                                None => {
                                    try!(visitor . end (  ));
                                    return Err(_serde::de::Error::invalid_length(3usize));
                                }
                            };
                        let __field4 =
                            match try!(visitor . visit :: < String > (  )) {
                                Some(value) => { value }
                                None => {
                                    try!(visitor . end (  ));
                                    return Err(_serde::de::Error::invalid_length(4usize));
                                }
                            };
                        let __field5 =
                            match try!(visitor . visit :: < String > (  )) {
                                Some(value) => { value }
                                None => {
                                    try!(visitor . end (  ));
                                    return Err(_serde::de::Error::invalid_length(5usize));
                                }
                            };
                        let __field6 =
                            match try!(visitor . visit :: < String > (  )) {
                                Some(value) => { value }
                                None => {
                                    try!(visitor . end (  ));
                                    return Err(_serde::de::Error::invalid_length(6usize));
                                }
                            };
                        try!(visitor . end (  ));
                        Ok(FindDefinitionResponse{file_path: __field0,
                                                  column: __field1,
                                                  line: __field2,
                                                  text: __field3,
                                                  context: __field4,
                                                  kind: __field5,
                                                  docs: __field6,})
                    }
                    #[inline]
                    fn visit_map<__V>(&mut self, mut visitor: __V)
                     ->
                         ::std::result::Result<FindDefinitionResponse,
                                               __V::Error> where
                     __V: _serde::de::MapVisitor {
                        let mut __field0: Option<String> = None;
                        let mut __field1: Option<usize> = None;
                        let mut __field2: Option<usize> = None;
                        let mut __field3: Option<String> = None;
                        let mut __field4: Option<String> = None;
                        let mut __field5: Option<String> = None;
                        let mut __field6: Option<String> = None;
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
                                                       _serde::de::Error>::duplicate_field("column"));
                                    }
                                    __field1 =
                                        Some(try!(visitor . visit_value :: <
                                                  usize > (  )));
                                }
                                __Field::__field2 => {
                                    if __field2.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("line"));
                                    }
                                    __field2 =
                                        Some(try!(visitor . visit_value :: <
                                                  usize > (  )));
                                }
                                __Field::__field3 => {
                                    if __field3.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("text"));
                                    }
                                    __field3 =
                                        Some(try!(visitor . visit_value :: <
                                                  String > (  )));
                                }
                                __Field::__field4 => {
                                    if __field4.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("context"));
                                    }
                                    __field4 =
                                        Some(try!(visitor . visit_value :: <
                                                  String > (  )));
                                }
                                __Field::__field5 => {
                                    if __field5.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("kind"));
                                    }
                                    __field5 =
                                        Some(try!(visitor . visit_value :: <
                                                  String > (  )));
                                }
                                __Field::__field6 => {
                                    if __field6.is_some() {
                                        return Err(<__V::Error as
                                                       _serde::de::Error>::duplicate_field("docs"));
                                    }
                                    __field6 =
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
                                try!(visitor . missing_field ( "column" )),
                            };
                        let __field2 =
                            match __field2 {
                                Some(__field2) => __field2,
                                None =>
                                try!(visitor . missing_field ( "line" )),
                            };
                        let __field3 =
                            match __field3 {
                                Some(__field3) => __field3,
                                None =>
                                try!(visitor . missing_field ( "text" )),
                            };
                        let __field4 =
                            match __field4 {
                                Some(__field4) => __field4,
                                None =>
                                try!(visitor . missing_field ( "context" )),
                            };
                        let __field5 =
                            match __field5 {
                                Some(__field5) => __field5,
                                None =>
                                try!(visitor . missing_field ( "kind" )),
                            };
                        let __field6 =
                            match __field6 {
                                Some(__field6) => __field6,
                                None =>
                                try!(visitor . missing_field ( "docs" )),
                            };
                        Ok(FindDefinitionResponse{file_path: __field0,
                                                  column: __field1,
                                                  line: __field2,
                                                  text: __field3,
                                                  context: __field4,
                                                  kind: __field5,
                                                  docs: __field6,})
                    }
                }
                const FIELDS: &'static [&'static str] =
                    &["file_path", "column", "line", "text", "context",
                      "kind", "docs"];
                deserializer.deserialize_struct("FindDefinitionResponse",
                                                FIELDS, __Visitor)
            }
        }
    };
#[derive(Debug)]
struct FindDefinitionResponse {
    pub file_path: String,
    pub column: usize,
    pub line: usize,
    pub text: String,
    pub context: String,
    pub kind: String,
    pub docs: String,
}
