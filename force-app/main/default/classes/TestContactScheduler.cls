@isTest(SeeAllData=true)
private class TestContactScheduler {
    @isTest
    static void testSchedulerExecutionWithRealData() {
        
        List<Contact> contactsWithBirthday = [
            SELECT Id, FirstName, Email, Birthdate 
            FROM Contact 
            WHERE Birthdate != NULL
            AND Email != NULL
        ];
        
        
        Date today = Date.today();
        List<Contact> contactsWithBirthdayToday = new List<Contact>();

        for (Contact contact : contactsWithBirthday) {
            if (contact.Birthdate.month() == today.month() && contact.Birthdate.day() == today.day()) {
                contactsWithBirthdayToday.add(contact);
            }
        }

        if (contactsWithBirthdayToday.isEmpty()) {
            System.assert(false, 'Нет контактов с датой рождения сегодня. Тест пропущен.');
            return;
        }

        Test.startTest();
        System.schedule('Test Birthday Scheduler', '0 0 6 * * ?', new ContactScheduler());
        Test.stopTest();

        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Test Birthday Scheduler'];
        System.assertEquals(1, jobs.size(), 'Scheduler executed successfully.');
    }
}