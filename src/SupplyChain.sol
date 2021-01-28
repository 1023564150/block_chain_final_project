pragma solidity ^0.4.24;

contract SupplyChain{
    struct Company{
        string name;
        mapping (string=>uint) own;
        mapping (string=>uint) owe;
        bool valid;
    }
    enum Event{
        purchase,
        loan,
        repayment
    }
    struct Transaction{
        string from;
        string to;
        uint amount;
        uint time;
        Event for_event;
        string event_detail;
    }
    mapping (string=>Company) private str_to_company;
    Company[] private companys;
    Transaction[] private transactions;

    function min(uint a,uint b) private pure returns(uint){
        if(a<=b){return a;}
        else{return b;}
    }

    function register_company(string memory name) public returns(bool){
        Company storage c=str_to_company[name];
        if(c.valid){return false;}
        c.name=name;
        c.valid=true;
        companys.push(c);
        return true;
    }

    function arise_transaction(string memory from,string memory to,uint amount,Event for_event,string memory event_detail) public returns(bool){
        Company storage c_from=str_to_company[from];
        Company storage c_to=str_to_company[to];
        if(!c_from.valid||!c_to.valid){return false;}

        if(for_event==Event.purchase||for_event==Event.loan){
            c_from.owe[to]+=amount;
            c_to.own[from]+=amount;
        }
        else{
            if(amount>min(c_from.owe[to],c_to.own[from])){return false;}
            c_from.owe[to]-=amount;
            c_to.own[from]-=amount;
        }

        Transaction memory t;
        t.from=from;
        t.to=to;
        t.amount=amount;
        t.time=now;
        t.for_event=for_event;
        t.event_detail=event_detail;
        transactions.push(t);

        return true;
    }

    function transfer(string memory self,string memory company_own,string memory company_owe,uint amount) public returns(bool){
        Company storage c=str_to_company[self];
        if(amount>min(c.own[company_own],c.owe[company_owe])){return false;}
        arise_transaction(company_own,self,amount,Event.repayment,"transfer");
        arise_transaction(self,company_owe,amount,Event.repayment,"transfer");
        arise_transaction(company_own,company_owe,amount,Event.loan,"transfer");
        return true;
    }

    function get_companys_size() public view returns(uint){
        return companys.length;
    }

    function get_company_by_index(uint i) public view returns(string memory name){
        return companys[i].name;
    }

    function inquire_company_in_companys(string memory goal) public view returns(bool){
        return str_to_company[goal].valid;
    }

    function inquire_single_own(string memory self,string memory company_own) public view returns(uint){
        return str_to_company[self].own[company_own];
    }

    function inquire_single_owe(string memory self,string memory company_owe) public view returns(uint){
        return str_to_company[self].owe[company_owe];
    }

    function inquire_sum_own(string memory self) public view returns(uint){
        uint sum=0;
        for(uint i=0;i<companys.length;i++){
            sum+=inquire_single_own(self,companys[i].name);
        }
        return sum;
    }

    function inquire_sum_owe(string memory self) public view returns(uint){
        uint sum=0;
        for(uint i=0;i<companys.length;i++){
            sum+=inquire_single_owe(self,companys[i].name);
        }
        return sum;
    }

    function get_transactions_size() public view returns(uint){
        return transactions.length;
    }

    function get_transaction_by_index(uint i) public view returns(string memory,string memory,uint,uint,Event,string memory){
        Transaction storage t=transactions[i];
        return (t.from,t.to,t.amount,t.time,t.for_event,t.event_detail);
    }
}