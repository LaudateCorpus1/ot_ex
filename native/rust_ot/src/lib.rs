extern crate rustler;

mod ot;
use ot::Operation;
use ot::OperationSeq;
use rustler::*;
use serde_rustler::{from_term, to_term};
use std::iter::FromIterator;

mod atoms {
    rustler::rustler_atoms! {
        atom ok;
        atom error;
        //atom __true__ = "true";
        //atom __false__ = "false";
    }
}

impl<'a> Decoder<'a> for Operation {
    fn decode(term: Term<'a>) -> Result<Operation, rustler::Error> {
        return Ok(from_term(term).unwrap());
    }
}

impl<'a> Encoder for OperationSeq {
    fn encode<'b>(&self, env: Env<'b>) -> Term<'b> {
        return to_term(env, self).unwrap();
    }
}

fn apply<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let code: String = args[0].decode()?;
    let operations: Vec<Operation> = args[1].decode()?;

    let operation: OperationSeq = OperationSeq::from_iter(operations);
    let utf16_encoded_code = code.encode_utf16().collect();

    let result = operation.apply(&utf16_encoded_code);

    match result {
        Ok(encoded_result) => {
            Ok((atoms::ok(), String::from_utf16_lossy(&encoded_result)).encode(env))
        }
        Err(err) => Ok(((atoms::error(), format!("{}", err))).encode(env)),
    }
}

fn transform<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let operation_a_arg: Vec<Operation> = args[0].decode()?;
    let operation_b_arg: Vec<Operation> = args[1].decode()?;

    let operation_a: OperationSeq = OperationSeq::from_iter(operation_a_arg);
    let operation_b: OperationSeq = OperationSeq::from_iter(operation_b_arg);

    match operation_a.transform(&operation_b) {
        Ok((left, right)) => Ok((atoms::ok(), left, right).encode(env)),
        Err(err) => Ok((atoms::error(), format!("{}", err)).encode(env)),
    }
}

fn transform_index<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let operation_a_arg: Vec<Operation> = args[0].decode()?;
    let index: u64 = args[1].decode()?;

    let operation_a = OperationSeq::from_iter(operation_a_arg);

    return Ok((operation_a.transform_index(index)).encode(env));
}

fn compose<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let operation_a_arg: Vec<Operation> = args[0].decode()?;
    let operation_b_arg: Vec<Operation> = args[1].decode()?;

    let operation_a = OperationSeq::from_iter(operation_a_arg);
    let operation_b = OperationSeq::from_iter(operation_b_arg);

    match operation_a.compose(&operation_b) {
        Ok(composed_op) => Ok((atoms::ok(), composed_op).encode(env)),
        Err(err) => Ok((atoms::error(), format!("{}", err)).encode(env)),
    }
}

fn compose_many<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let mut operation_args: Vec<Vec<Operation>> = args[0].decode()?;

    let operation_arg_a = operation_args.remove(0);
    let mut final_result = OperationSeq::from_iter(operation_arg_a);

    for op_arg in operation_args {
        let new_op = OperationSeq::from_iter(op_arg);

        match final_result.compose(&new_op) {
            Ok(result) => final_result = result,
            Err(ot_error) => return Ok((atoms::error(), format!("{}", ot_error)).encode(env)),
        }
    }

    return Ok((atoms::ok(), final_result).encode(env));
}

rustler_export_nifs!(
    "Elixir.Rust.OT",
    [
        ("apply", 2, apply),
        ("transform", 2, transform),
        ("transform_index", 2, transform_index),
        ("compose", 2, compose),
        ("compose_many", 1, compose_many)
    ],
    None
);
