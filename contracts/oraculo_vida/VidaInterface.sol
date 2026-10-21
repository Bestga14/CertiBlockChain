// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface VidaInterface {
    function estaVivo(address persona) external view returns (bool vivo, uint256 actualizado);
}