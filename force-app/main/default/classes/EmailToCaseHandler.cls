/**
 * @description EmailToCaseHandler
 * This Apex class implements the Messaging.InboundEmailHandler interface
 * to process incoming emails and create new Case records.
 *
 * It's designed for API Version 64.0 (Summer '25).
 */
global class EmailToCaseHandler implements Messaging.InboundEmailHandler {

    /**
     * @description handleInboundEmail
     * This method is called by the Email Service when an email is received.
     * It parses the email content and creates a new Case.
     *
     * @param email The Messaging.InboundEmail object representing the incoming email.
     * @param envelope The Messaging.InboundEnvelope object containing email metadata (from/to addresses).
     * @return Messaging.InboundEmailResult The result of the email processing (success/failure).
     */
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            // 1. Create a new Case object
            Case newCase = new Case();

            // 2. Populate Case fields from the inbound email
            newCase.Subject = email.subject != null ? email.subject : 'No Subject';
            newCase.Description = email.plainTextBody != null ? email.plainTextBody : 'No Body';
            newCase.SuppliedEmail = envelope.fromAddress;
            newCase.SuppliedName = envelope.fromAddress; // You might parse email.fromName for a better name

            // Example: Set a default status and origin
            newCase.Status = 'New';
            newCase.Origin = 'Email'; // Or 'Web', 'Phone', etc. depending on your process

            // Optional: Set Record Type if you have multiple Case record types
            // Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Case').getRecordTypeId();
            // if (caseRecordTypeId != null) {
            //     newCase.RecordTypeId = caseRecordTypeId;
            // }

            // Optional: Assign to a Queue based on the 'to' address or subject keywords
            // Example: If the email was sent to 'support@yourorg.com'
            // if (envelope.toAddresses != null && !envelope.toAddresses.isEmpty() && envelope.toAddresses[0].contains('support')) {
            //     Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Support Queue' LIMIT 1];
            //     if (queue != null) {
            //         newCase.OwnerId = queue.Id;
            //     }
            // }

            // 3. Insert the new Case
            insert newCase;
            System.debug('New Case created: ' + newCase.Id);

            // 4. Handle Attachments (if any)
            if (email.binaryAttachments != null && !email.binaryAttachments.isEmpty()) {
                List<ContentVersion> cvsToInsert = new List<ContentVersion>();
                List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();

                for (Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments) {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = attachment.fileName;
                    cv.PathOnClient = attachment.fileName;
                    cv.VersionData = attachment.body;
                    cv.Origin = 'H'; // C = Chatter, H = Content, S = Salesforce Files
                    cvsToInsert.add(cv);
                }

                if (!cvsToInsert.isEmpty()) {
                    insert cvsToInsert;

                    for (ContentVersion cv : cvsToInsert) {
                        // Link the ContentDocument to the Case
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
                        cdl.LinkedEntityId = newCase.Id;
                        cdl.ShareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                        cdlToInsert.add(cdl);
                    }

                    if (!cdlToInsert.isEmpty()) {
                        insert cdlToInsert;
                        System.debug(cdlToInsert.size() + ' attachments linked to Case ' + newCase.Id);
                    }
                }
            }

            // 5. Indicate success
            result.success = true;

        } catch (Exception e) {
            System.debug('Error processing inbound email: ' + e.getMessage());
            // Indicate failure and optionally send an error message back to the sender
            result.success = false;
            result.message = 'Failed to create case: ' + e.getMessage();
            // You might also want to log this error to a custom object or use platform events for monitoring.
        }

        return result;
    }
}