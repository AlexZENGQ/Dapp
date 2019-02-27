pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}

contract AlexZENGCoin {
    // Token基本信息
    // mapping 和 public 都可以自动生成 getter和setter
    // setter:修改变量要调用这个函数
    // getter:外部获取变量的值 
    string public name;            // 名字
    string public symbol;          // 符号
    uint8 public decimals = 18;   // 官方推荐小数位18位
    uint256 public totalSupply;    // 代币总计数
    address payable private creator; //定义私人交易账户creator

    // 声明了一个映射类型的变量 balanceOf，用于存储每个账户中对应的余额（ Token 数量）
    mapping (address => uint256) public balanceOf;

    // 映射的映射，授权的额度以及其下的额度
    mapping (address => mapping (address => uint256)) public allowance; 
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // 构造函数(名字与合约名字一致)，balanceOf余额构造
    constructor(
    	uint256 initialSupply,  // 用户输入的想要多少枚代币
    	string memory tokenName,
    	string memory tokenSymbol
    ) public
    {	
    	// 对用户传入的数量进行小数位的换算
    	totalSupply = initialSupply * 10 ** uint256(decimals); 
    	// 将所有的代币都放入消息发送者(创建者)的账户中
    	balanceOf[msg.sender] = totalSupply;
    
    	name = tokenName;
    	symbol = tokenSymbol;
    	creator = msg.sender;
    }
    
    
    // 核心部分，交易函数
    function _tranfer (address _from, address _to, uint _value)
    internal {
    
    	//require为必须满足括号内的条件，为真才能进行交易
    	require(_to != address(0x0)); // 不能向地址为零的转钱
    	require(balanceOf[_from] >= _value);// 出账的账户的余额大于转出的钱
    	require(balanceOf[_to] + _value > balanceOf[_to]); // 入账的账户收得的加上原来的要大于原来的钱
    	
    	// 校验一：交易前的双方的余额总额
    	uint previousBalances = balanceOf[_from] + balanceOf[_to];
    
    	//真实逻辑，转出的钱会减掉，收到的钱会增多
    	balanceOf[_from] -= _value;
    	balanceOf[_to] += _value;
    
    //     // 广播事件，告诉大家发生了一笔转账
    	emit Transfer(_from, _to, _value);
    
    	//校验二：交易后的双方余额总额，应该与交易前的相等
    	assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    
    //授权交易
    function approve (address _spender, uint256 _value) public returns (bool success)
    
    {   
    	//设置授权额度，allowance指的是授权额度的映射，地址下的对应的人赋一定量的额度
    	allowance[msg.sender][_spender] = _value;
    	return true;
    }
    
    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success)
    
    {
    	//设置授权支付，先确认是否有授权的额度
    	require(_value <= allowance[_from][msg.sender]);
    
    	//接着从打款人这边减去金额给到收款人这边
    	allowance[_from][msg.sender] -= _value;
    	_tranfer (_from, _to, _value);
    	return true;
     }
    
    /*
    以上则是代币基本的操作，TokenERC20的规范,
    此时你个人的账户里面已经有代币了
    */
    
    
    /*
    以下是拓展的功能，规范以外的可以自己写的功能
    */
    
    //通过ETH购买代币(实现自动售卖)
    //wei 是ETH的一个单位，具体可查：https://etherconverter.online/
    function BuyToken() public payable returns (bool success) {
    	uint256 weiAmount = msg.value;  //合约的额度值
    	uint256 tokens;
    	uint rate = 1000;  //设定汇率，这里设定 1ETH 换 1000代币
    	//ETH转换成代币数量
    	tokens = weiAmount * ( 10 ** uint256(decimals)/1000000000000000000) * rate;
    
    	//代币是是否大于零的条件判断后进行交易
    	require(tokens > 0);
    	_tranfer(creator, msg.sender, tokens);
    	return true;
    }
    
    //提取智能合约上的ETH
    function getETH() public
    {
    	//保证这个地址上的有余额，并且消息发送者是合约创造人，这样才能提取给自己
    	require( address(this).balance > 0 && msg.sender == creator);
    
    	//将当前合约上的ETH余额转移到这个合约创造人的账户尚
        creator.transfer( address(this).balance);
    }

}
    

/**solidity语法**/

//版本说明
pragma solidity ^0.4.21;

//状态变量(类型和运算符)
int/uint(**n)    //uint是无符号整形（0和正整形）
fixed/ufixed     //fixed是定长变量
string/bytes     //变长，bytes是二进制
bool
address(.balance .transfer .send .call) //余额，转账，写，读
mapping( mapping( address => uint ) )   //映射


string public name; //public指的是可以外部访问的变量
string public symbol; //public会自动生成getter和setter
uint256 public decimals; //private是指私有变量
uint256 public total totalSupply; //internal 在关联合约可访问


//结构

struct Vote {
	uint weight;
	bool voted;
	address delegate;
	uint vote;
}

//枚举
enum State { Created, Locked, Inactive }


//函数（强类型语言）

function mul(uint256 a, uint256b)
internal pure returns (uint256)
{
	if (a==0) {
		return 0;
	}
	uint256 c = a * b;
	assert(c / a == b);
	return c;
}

函数可见性：public / private / internal / external
其中external表示该函数可以被外部合约和交易调用

函数类型：pure(纯函数) 、view(只读) 、payable(有交易) 

函数返回值：因为是强类型语言，不仅先要声明变量类型，还要声明返回类型


//函数修饰器(Modifier),指一种代码片段的重用机制
contrct Purchase
{
	address public seller;

	modofier onlySeller() {
		//modofier
		require(msg.sender == seller);
		_; // '_；'指的是继续执行下面的代码，在其他部分如果需要重用的话，下划线上面的代码就不用重新写了
	}

	function abort() public onlySeller
	{
		//modifier
	}
}


//事件（广播机制,全网可以监听）

event Deposit(
	address indexed_from;
	bytes32 index_id;
	uint _value
);
function deposit (bytes32 _id) public payable
{
	emit Deposit(msg.sender, _id, msg.value);
}


