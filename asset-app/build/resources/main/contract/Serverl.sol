pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./Table.sol";


contract Server 
{
    constructor() public
    {
        createCompanyTable();
        createReceiptTable();
    }

    function createCompanyTable() private
    {
        TableFactory tf = TableFactory(0x1001);
        tf.createTable("t_company", "name", "acount, balance, debt, c_type");
    }

    function createReceiptTable() private
    {
        TableFactory tf = TableFactory(0x1001);
        tf.createTable("t_receipt", "id", "from, to, amount, date");
    }
    
    //company
    function insertCompany(string _name, string _acount, int _balance, int _debt, string c_type) public returns (int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_company");
        Entry entry = table.newEntry();
        entry.set("name", _name);
        entry.set("acount", _acount);
        entry.set("balance", _balance);
        entry.set("debt", _debt);
        entry.set("c_type", c_type);
        int count = table.insert(_name, entry);
        return count;
    }
    
    function selectCompany(string name) public constant returns (string, string, int, int, string)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_company");
        Entries entries = table.select(name, table.newCondition());
        Entry entry = entries.get(0);
        return (entry.getString("name"), entry.getString("acount"), entry.getInt("balance"), entry.getInt("debt"), entry.getString("c_type"));
    }
    
    function updateCompany(string name, string acount, int balance, int debt, string c_type) public returns (int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_company");
        Entry entry = table.newEntry();
        entry.set("name", name);
        entry.set("acount", acount);
        entry.set("balance", balance);
        entry.set("debt", debt);
        entry.set("c_type", c_type);
        Condition condition = table.newCondition();
        condition.EQ("name", name);
        int count = table.update(name, entry, condition);
        return count;
    }

    function register(string name, string acount, int balance, int debt, string c_type) public returns (int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_company");
        Entries entries = table.select(name, table.newCondition());
        if (entries.size() != 0)
            return -1;
        int count = insertCompany(name, acount, balance, debt, c_type);
        return count;
    }
    
    function login(string name, string acount) public constant returns (int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_company");
        Entries entries = table.select(name, table.newCondition());
        if (entries.size() == 0)
            return -1;
        Entry entry = entries.get(0);
        if (keccak256(abi.encodePacked(entry.getString("acount"))) == keccak256(abi.encodePacked(acount)))
            return 1;
        else
            return -1;
    }
    
    //receipt
    function selectReceipt(string _id) public constant returns(string , string , string , int , string)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_receipt");
        Entries entries = table.select(_id, table.newCondition());
        Entry entry = entries.get(0);
        return (entry.getString("id"), entry.getString("from"), entry.getString("to"), entry.getInt("amount"), entry.getString("date"));
    }
    
    function insertReceipt(string _id, string _from, string _to, int _amount, string _date) public returns (int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_receipt");
        Entry entry = table.newEntry();
        entry.set("id", _id);
        entry.set("from", _from);
        entry.set("to", _to);
        entry.set("amount", _amount);
        entry.set("date", _date);
        int count = table.insert(_id, entry);
        return count;
    }
    
     function updateReceipt(string _id, string _from, string _to, int _amount, string _date) public returns (int)
     {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_receipt");
        Entry entry = table.newEntry();
        entry.set("id", _id);
        entry.set("from", _from);
        entry.set("to", _to);
        entry.set("amount", _amount);
        entry.set("date", _date);
        Condition condition = table.newCondition();
        condition.EQ("id", _id);
        int count = table.update(_id, entry, condition);
        return count;
    }
    
    function removeReceipt(string _id) public returns (int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_receipt");
        Condition condition = table.newCondition();
        condition.EQ("id", _id);
        int count = table.remove(_id, condition);
        return count;
    }
    
    function purchase(string _id, string _from, string _to, int _amount, string _date) public returns(int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_company");
        Entries entries1 = table.select(_from, table.newCondition());
        Entries entries2 = table.select(_to, table.newCondition());
        if (entries1.size() == 0 || entries2.size() == 0)
            return -1;
        int count = insertReceipt(_id, _from, _to, _amount, _date);
        return count;
    }
    
    function transfer (string _id, string _from, string _to,string _to_to, int _from_prev_amt, int _to_prev_amt, int _amount, string dd) public returns(int) 
    {
        if(_amount > _from_prev_amt || _amount > _to_prev_amt)
        {
            return -1;
        }
        updateReceipt(_id, _from, _to, _from_prev_amt - _amount, dd);
        updateReceipt(_id, _to, _to_to, _to_prev_amt - _amount, dd);
        insertReceipt(_id, _from, _to_to, _amount, dd);
        return 1;
    }
    function financing(string _id, string _from, string _to, int _amount, string _date) public returns (int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table = tf.openTable("t_company");
        Entries entries1 = table.select(_from, table.newCondition());
        Entries entries2 = table.select(_to, table.newCondition());
        if (entries1.size() == 0 || entries2.size() == 0)
            return -1;
        //假设bank不会破产
        updateCompany(entries1.get(0).getString("name"), entries1.get(0).getString("acount"), 
            entries1.get(0).getInt("balance") + _amount, entries1.get(0).getInt("debt") - _amount,
                entries1.get(0).getString("c_type"));
        int count = insertReceipt(_id, _from, _to, _amount, _date);
        return count;
    }
    
    function repay(string _id) public returns (int)
    {
        TableFactory tf = TableFactory(0x1001);
        Table table1 = tf.openTable("t_receipt");
        Entries entries = table1.select(_id, table1.newCondition());
        if (entries.size() == 0)
            return -1;
        Table table = tf.openTable("t_company");
        Entries entries1 = table.select(entries.get(0).getString("from"), table.newCondition());
        Entries entries2 = table.select(entries.get(0).getString("to"), table.newCondition());
        updateCompany(entries1.get(0).getString("name"), entries1.get(0).getString("acount"), 
            entries1.get(0).getInt("balance") - entries.get(0).getInt("amount"), entries1.get(0).getInt("debt"),
                entries1.get(0).getString("c_type"));
        updateCompany(entries2.get(0).getString("name"), entries2.get(0).getString("acount"), 
            entries2.get(0).getInt("balance") + entries.get(0).getInt("amount"), entries2.get(0).getInt("debt") - entries.get(0).getInt("amount"),
                entries2.get(0).getString("c_type"));
        int count = removeReceipt(_id);
        return count;
    }


}