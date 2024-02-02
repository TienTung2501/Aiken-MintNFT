import {
    Blockfrost,
    C,
    Data,
    Lucid,
    SpendingValidator,
    TxHash,
    fromHex,
    toHex,
    toUnit,
    Constr,
    MintingPolicy,
    fromText,
    mintingPolicyToId,
    applyParamsToScript,
    applyDoubleCborEncoding,
    attachSpendingValidator,
    UTxO,
  } from "https://deno.land/x/lucid@0.10.7/mod.ts";
  import * as cbor from "https://deno.land/x/cbor@v1.4.1/index.js";

  const BLOCKFROST = "preview5ZEeQD8I1W8MHLEwlKy7NEmXKjSPJhRZ"
 
  const lucid = await Lucid.new(
    new Blockfrost(
      "https://cardano-preview.blockfrost.io/api/v0",
      BLOCKFROST,
    ),
    "Preview",
  );
  //transaction
async function mintToken() {
    const tx = await lucid
    .newTx()
    .mintAssets({
        [toUnit(mintCS,tokenName,100)]: BigInt(1),
        [toUnit(mintCS,tokenName,444)]: BigInt(1)

    },redeemer)
    .attachMintingPolicy(mint)
    .payToContract(lAddress, {inline: lDatum}, {[toUnit(mintCS,tokenName,100)]: BigInt(1)})
    .payToContract(lAddress, {inline: lDatum}, {[toUnit(mintCS,tokenName,444)]: BigInt(1000)})
    .complete()
    
    const signedTx = await tx.sign().complete()

    return signedTx.submit()
}
async function redeemToken() {
    const tx = await lucid
    .newTx()
    .collectFrom()
    .attachSpendingValidator()
    .payToAddress()
    .payToContract()
    .complete()

    const signedTx = await tx.sign().complete()

    return signedTx.submit()
}
async function updateToken() {
    const tx = await lucid
    .newTx()
    .collectFrom()
    .attachSpendingValidator()
    .payToContract()
    .complete()
    
    const signedTx = await tx.sign().complete()

    return signedTx.submit()
}
async function splitUtxos() {
    
}