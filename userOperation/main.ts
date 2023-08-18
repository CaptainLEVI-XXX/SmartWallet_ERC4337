import * as dotenv from "dotenv";
import { ethers } from "ethers";
import { Client, Presets } from "userop";
import { tokenToString } from "typescript";

dotenv.config();
const signingKey = process.env.SIGNING_KEY || " ";
const rpcURL = process.env.RPC_URL || " ";


async function approveAndSendToken(
    to: string,
    token: string,
    value: string): Promise<any[]> {
    const ERC20_ABI = require("./abi.json");
    const provider = new ethers.providers.JsonRpcProvider(rpcURL);
    const erc20 = new ethers.Contract(token, ERC20_ABI, provider);
    const decimals = await Promise.all([erc20.decimals()]);
    const amount = ethers.utils.parseUnits(value, decimals);


    const approve = {
        to: token,
        value: ethers.constants.Zero,
        data: erc20.interface.encodeFunctionData("approve", [to, amount]),
    };

    const send = {
        to: token,
        value: ethers.constants.Zero,
        data: erc20.interface.encodeFunctionData("transfer", [to, amount]),
    };

    return [approve, send];
}
async function main() {

    const signer = new ethers.Wallet(signingKey);
    const builder = await Presets.Builder.Kernel.init(signer, rpcURL);
    const address = builder.getSender();
    console.log(`Account address : ${address}`);

    const to = address;
    const token = "0x3Dee86F1159977dfcE6c90Fd39aB3D49488FF051";
    const value = "0";

    const calls = await approveAndSendToken(to, token, value);
    //console.log(calls);

    builder.executeBatch(calls);
    console.log(builder.getOp());

    // send the user Operation
    const client = await Client.init(rpcURL);
    const res = await client.sendUserOperation(builder.executeBatch(calls), {
        onBuild: (op) => console.log("Signed UserOperation:", op),
    });

    console.log(`UserOpHash: ${res.userOpHash}`);
    console.log("Waiting for transaction...");
    const ev = await res.wait();
    console.log(`Transaction hash: ${ev?.transactionHash ?? null}`);
}


export default main()


// run npx ts-node main.ts 