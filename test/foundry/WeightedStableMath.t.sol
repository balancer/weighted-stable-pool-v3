// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { FixedPoint } from "@balancer-labs/v3-solidity-utils/contracts/math/FixedPoint.sol";

import { WeightedStableMath } from "../../contracts/lib/WeightedStableMath.sol";

contract WeightedStableMathTest is Test {
    using FixedPoint for uint256;

    function testComputeInvariantInBalance__Fuzz(
        uint256 linearInvariant,
        uint256 amplificationFactor,
        uint256 weight1
    ) public pure {
        linearInvariant = bound(linearInvariant, 1e16, 1e6 * 1e18);
        amplificationFactor = bound(amplificationFactor, 1e3, 50000 * 1e3);
        weight1 = bound(weight1, 1e16, 99e16);
        uint256 weight2 = FixedPoint.ONE - weight1;

        uint256[] memory balances = new uint256[](2);
        balances[0] = linearInvariant.mulDown(weight1);
        balances[1] = linearInvariant.mulDown(weight2);

        uint256[] memory weights = new uint256[](2);
        weights[0] = weight1;
        weights[1] = weight2;

        uint256 invariant = WeightedStableMath.computeInvariant(amplificationFactor, balances, weights);

        assertApproxEqAbs(invariant, linearInvariant, 1, "Invariant does not match");
    }
}
