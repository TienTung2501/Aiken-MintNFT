use aiken/bytearray
use aiken/dict
use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction.{InlineDatum, Mint, ScriptContext, Spend, Transaction}
use aiken/transaction/credential.{VerificationKey}
use aiken/transaction/value

// reference Prefix
const refPrefix = #"000643b0"

// fraction Prefix
const fracPrefix = #"001bc280"

// PKH 
type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>

type TokenDatum{
    name: ByteArray,
    image: ByteArray,
    mediType: ByteArray,
}
type DisDatum{
    a:Int,
}
type MintAction{
    a: Int,// redeemer value
    b: Int,// numner of fractionalies tokens
    tn: ByteArray// token name
}

// Helper Functions //
  //asset name
fn make_token_names(tn) -> List<value.AssetName>{
    let tokeName: value.AssetName = tn
    let refTn = tokeName 
    let fracTn = tokeName
    //return
    [refTn, fracTn]
}
fn fration_token_prefix(tn){
    let token_names= make_token_names(tn)
    let token_name_prefix = [refPrefix, fracPrefix]
    list.map2(
        token_name_prefix,
        token_names,
        fn(a,b){bytearray.concat(a,b)}
    )
}

fn compare_token_names(an: value.AssetName, tn: Option<ByteArray>) -> Bool{
    expect Some(tn) = tn 
    an==tn
}
fn tx_signed_by(tx: Transaction, pkh: VerificationKeyHash){
    list.has(tx.extra_signatories,pkh)
}
validator(owner: VerificationKeyHash){//locking Validator
    //Token Minting Policy
    fn mint(r: MintAction,c: ScriptContext)-> Bool{
        let ScriptContext { transaction, purpose }= c

        expect Mint(policy_id) = purpose
        
        let Transaction{mint, output,extra_signatories ..}=transaction

        expect [(ref_asset_name, ref_amount), (frac_asset_name, frac_amount)]= 
            mint
            |> value.from_minted_value
            |>value.toke(policy_id)
            |>dict.to_list()

        expect tx_signed_by(transaction,owner)     //tx signed by owner
        when r.a is{
            1-> { 
                // mint 1x 100 Prefix Token
                //sent to loking Validator or sent to output
                expect list.any(outputs,fn(output){
                    expect InlineDatum(datum)= output.datum 
                    expect datum: TokenDatum = datum
                    value.quantity_of(output.value, policy_id, ref_asset_name)== 1
                })
                // mint 1000x 444 Prefix Token
                // send to distribution Validator or delivered to one output
                expect list.any(outputs, fn(output){
                    value.quantity_of(output.value,policy_id,frac_asset_name)==1000
                    // might want to mint a different amount of fracs /NFT
                })
                //enforce token name
                let token_name_list = fration_token_prefix(r.tn)

                let ref_tn_check = 
                    compare_token_names(ref_asset_name,list.at(token_name_list,0))
                //compare ref name to token name list
                let frac_tn_check = 
                    compare_token_names(frac_asset_name,list.at(token_name_list,1))
                //compare frac names to token name list
                // tn = token_name
                ref_amount ==1 && frac_amount == r.b && ref_tn_check && frac_tn_check
            }

            // tx signed by owner
            _-> {
                let token_name_list = fration_token_prefix(r.tn)

                let ref_tn_check = 
                    compare_token_names(ref_asset_name,list.at(token_name_list,0))
                //compare ref name to token name list
                let frac_tn_check = 
                    compare_token_names(frac_asset_name,list.at(token_name_list,1))
                //compare frac names to token name list
                // tn = token_name
                ref_amount ==-1 && frac_amount == -r.b && ref_tn_check && frac_tn_check
            }
            // burn -1 RefToken && -1000 FracToken
            //tx signed by owner
        }
    }
}
type LockAction{
    a: Int,
    b: Int
}
//Ref Token Locking Validator
validator(owner: VerificationKeyHash, cs: value.PolicyId){
    fn lock(d: TokenDatum, r: LockAction,c: ScriptContext) -> Bool{
        when r.a is{
            1 -> True
            // tx signed by Owner
            // output contains single token (PolicyID)
            _ -> True
            //tx signed by Owner
        }
    }
}
type DisAction{
    a: Int,
    b: Int
}
//Distribution Validator// giai dot tai san
validator(owner: VerificationKeyHash){
    fn distro(d: DisDatum, r: DisAction, c: ScriptContext) -> Bool {
        when r.a is{
            1 -> True
            // has one output
            // has one asset less
            _ -> True
            //tx signed by "Owner"
        }
    }
}
//done