trigger UpdateAccount on Account (before insert,after insert,before update) {
    if(trigger.isinsert&&trigger.isbefore){
        for(Account a:trigger.new){
            a.Active__c=false;
        }
    }
    if(trigger.isinsert&&trigger.isafter){
        list<SQX_Team_Members__c> lstTm=new list<SQX_Team_Members__c>();
        for(account a:trigger.new){
            for(integer i=1;i<3;i++){
                SQX_Team_Members__c tm=new SQX_Team_Members__c();
                tm.Account__c=a.Id;
                tm.Name='Team member'+i;
                lstTm.add(tm);
            }
        }
        system.debug('---------->'+lstTm);
        insert lstTm;
    }
    if(trigger.isupdate&&trigger.isbefore){
        list<SQX_Team_Members__c> tm=[select id,Account__c,Member_Type__c from SQX_Team_Members__c where Account__c=:trigger.New];
        system.debug('00000000000'+tm);
        set<string> membertypes=new set<string>();
        for(SQX_Team_Members__c t:tm){
            if(t.Member_Type__c=='HR'||t.Member_Type__c=='Admin'){
            membertypes.add(t.Member_Type__c);
            }
        }
        
            for(account a:trigger.new){
                List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name ='Account_Admin') and AssigneeId IN (select Id from User where id=:UserInfo.getUserId()) ];
                system.debug('111111111'+psas);
                Account oldAccount = Trigger.oldMap.get(a.ID);
                if(membertypes.size()!=2&&a.Active__c!=oldAccount.Active__c){
                a.adderror('Member type should be HR and Admin');
                }
                else if(psas.size()==0){
                    a.adderror('User should have Account Admin permission set assigned');	
                }
            }
        
            
        
    }

}