import './lib/Standard20Token.sol';
import './lib/Minted.sol';
import './lib/Managed.sol';
import './interface/VaultInterface.sol';
import './interface/VaoInterface.sol';
import './lib/SafeMath.sol';



pragma solidity ^0.4.11;

/**
 * @title NEVTOKEN
 * @author Carlos Buendía (@buendiadas)
 * @dev NEVToken aims to create a new pattern in token design, where variables regarding the token economy are modular and can evolve by unlimited forks
 */

contract NEVToken is Standard20Token { // TODO Check how to reduce inheritance
    using SafeMath for uint;

    mapping (bytes=> address) gadgetStack;  //Namehash of the gadget => Address of the gadget

    modifier has(bytes32 gadget){
        require(gadgetStack[gadget] != 0x00);
        _;
    }
    modifier only(string label){
      bytes memory labelBytes = bytes(s);
      require(msg.sender == gadgetStack[labelBytes])
    }

    /**
    * @dev Mints an additional amount of tokens, only available for the Minter
    * @param _recipient Address that will receive the new created supply
    * @param _value Amount to be minted and received by _recipient
    **/

    function mint(address _recipient, uint256 _value)
        internal
        returns (bool _success){
        balances[_recipient]=balances[_recipient].add(_value);
        totalSupply=totalSupply.add(_value);
        Mint(_recipient, _value);
        return true;
    }

    /**
    * @dev Destroys an amount of tokens from msg.sender.
    * This allows the creation of intermediate conditions like the token redemption.
    * For security reasons, this could be done in a 2 way verification mode.
    **/

    function destroy(address _recipient, uint256 _value)
        internal
        returns (bool _success){
        balances[_recipient]=balances[_recipient].sub(_value);
        totalSupply=totalSupply.sub(_value);
        Destroy(_recipient, _value);
        return true;
    }

    /**
    * @dev Function that allow external minters to add additional supply
    * @param _recipient Same than in the Mint Contract: Account that will receive the additional supply
    * @param _value Same than in the Mint Contract: Amount to be received by _recipient
    **/
    function externalMint(address _recipient, uint256 _value)
        external
        only("minter")
        returns (bool _success){
        if(!mint(_recipient, _value)) throw;
        return true;
    }

    /**
    * @dev Function that allow external minters to add additional supply
    * @param _recipient Same than in the Mint Contract: Account that will receive the additional supply
    * @param _value Same than in the Mint Contract: Amount to be received by _recipient
    **/
    function externalDestroy(address _recipient, uint256 _value)
        external
        only("minter")
        returns (bool _success){
        if(!destroy(_recipient, _value)) throw;
        return true;
    }

    /**
    * @dev Upgrades the current VAO version with another. Be cautious when calling it, it will destroy your current VAO tokens
    * @param _version Address that will receive the new token version
    * @param _amount Amount to be sended to the new version
    **/

    function upgrade(address _version, uint256 _amount)
        upgradeAllowed
        returns (bool _success){
        NEVToken nevToken=NEVToken(_version);
        if (_amount == 0) throw;
        if(!destroy(msg.sender, _amount)) throw;
        if (!childVAO.upgradeFrom(msg.sender, _amount)) throw;
        Upgrade(msg.sender, _version, _amount);
        return true;
    }

    /**
    * @dev Allows incoming upgrades from another VAO contract
    * Restricted to the Parent set in the
    * Before changing this method, be sure that the only point calling to this method is upgrade
    * @param _account Account that has decided to upgrade the tokens
    * @param _amount Amount that has been destroyed in this contract.
    *
    **/

    function upgradeFrom(address _account, uint256 _amount)
        onlyParent
        returns (bool _success){
        if(!mint(_account,_amount)) throw;
        return true;
    }


    //********************************************************
    // Events
    //********************************************************

    event Mint(address indexed _to, uint256 _value);
    event Upgrade (address _from, address _version, uint256 _amount);

}
