public class ChamadoBusinessNovo {
	
    public ChamadoBusinessNovo(ApexPages.StandardController stdController){
        Id chamadoId = stdController.getId();
    }
    public ChamadoBusinessNovo(){}
    
    public void enviaConfirmacaoNovoChamado (List<chamado__c> chamados) { 

        if (chamados.isEmpty()){
            return;
        }

        Set<Id> chamadoIds = new Set<Id>();
        Map<Id,Id> accountsMap = new Map<Id,Id>();//conta,chamado
        Map<Id,Id> contactsMap = new Map<Id,Id>();//chamado,contato
        Map<Id,Id> chamadosMap = new Map<Id,Id>();//chamado,conta
        Map<Id,Id> membersMap = new Map<Id,Id>();//chamado,membro
        Map<Id,String> chamadoUserMap = new Map<Id,String>();//chamado,UsuárioMembro
        Map<Id,String> chamadoUserNameMap = new Map<Id,String>();//chamado,UsuárioMembro
        Map<Id,String> chamadoContatoMap = new Map<Id,String>();//chamado,Contato
        Map<Id,String> chamadoContatoNameMap = new Map<Id,String>();//chamado,Contato

        for (Chamado__c chamado : chamados){
            chamadoIds.add(chamado.Id);
            accountsMap.put(chamado.Cliente__c,chamado.Id);
            contactsMap.put(chamado.Id,chamado.Contato__c);
            chamadosMap.put(chamado.Id,chamado.Cliente__c);
        }

        List<AccountTeamMember> members = [SELECT AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :accountsMap.keySet() AND TeamMemberRole = 'SDS'];

        for (AccountTeamMember member : members){
            if (accountsMap.containsKey(member.AccountId)){
                membersMap.put(accountsMap.get(member.AccountId), member.UserId);
            }
        }

        List<User> users = [SELECT Id, Name, FirstName, Email FROM User WHERE ID IN :membersMap.values()];
        
        for (User us : users){
            for (Id chamadoId : chamadoIds){
                if (membersMap.containsKey(chamadoId) && membersMap.get(chamadoId) == us.Id){
                    chamadoUserMap.put(chamadoId,us.Email);
                    chamadoUserNameMap.put(chamadoId,us.FirstName);
                }
            }
        }

        List<Contact> contatos = [SELECT Id, Name, FirstName, Email FROM Contact WHERE ID IN :contactsMap.values()];
        
        for (Contact contato : contatos){
            for (Id chamadoId : chamadoIds){
                if (contactsMap.containsKey(chamadoId) && contactsMap.get(chamadoId) == contato.Id){
                    chamadoContatoMap.put(chamadoId,contato.Email);
                    chamadoContatoNameMap.put(chamadoId,contato.FirstName);
                }
            }
        }

        EmailTemplate templateAbertura = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate 
                                           WHERE DeveloperName = 'ConfirmacaoAbertura'];

        EmailTemplate templateAviso = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate 
                                              WHERE DeveloperName = 'AvisoAbertura'];


        
        EnviaEmailNovoChamado(templateAbertura, chamados, chamadoUserMap, chamadoUserNameMap);
        EnviaEmailNovoChamado(templateAviso, chamados, chamadoContatoMap, chamadoContatoNameMap);
        
             
    }

    private void EnviaEmailNovoChamado(EmailTemplate template, List<Chamado__c> chamados, Map<Id,String> chamadoEmail, Map<Id,String> chamadoNome){

        for (chamado__c chamado: chamados){

            String HtmlBody = template.HtmlValue.replace('nome', chamadoNome.get(chamado.Id));

            HtmlBody = HtmlBody.replace('link',chamado.Id);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[] { chamadoEmail.get(chamado.Id) });

            mail.setSubject(template.Subject);

            mail.setHtmlBody(HtmlBody);

            //mail.setPlainTextBody(template.Body.replace('nome', Name));    

            mail.setSaveAsActivity(false);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        }   
    }
}