import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can deposit and withdraw funds correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const amount = 1000000; // 1 STX
    
    // First create a guild
    let block = chain.mineBlock([
      Tx.contractCall("guild-core", "create-guild", 
        [types.ascii("Test Guild")], 
        wallet_1.address
      )
    ]);
    
    // Then deposit funds
    block = chain.mineBlock([
      Tx.contractCall("guild-treasury", "deposit",
        [types.uint(1), types.uint(amount)],
        wallet_1.address
      )
    ]);
    assertEquals(block.receipts[0].result.expectOk(), true);
    
    // Test withdrawal
    block = chain.mineBlock([
      Tx.contractCall("guild-treasury", "withdraw",
        [types.uint(1), types.uint(amount)],
        wallet_1.address
      )
    ]);
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});
