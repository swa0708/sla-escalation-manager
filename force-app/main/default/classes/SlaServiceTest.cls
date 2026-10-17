@IsTest
private class SlaServiceTest {

    @IsTest
    static void highPriorityAddsFourHours() {
        Datetime startTime = Datetime.newInstance(2026, 1, 1, 9, 0, 0);

        Datetime result = SlaService.calculateDueDate(startTime, 'High');

        System.assertEquals(startTime.addHours(4), result, 'High priority should add 4 hours');
    }

    @IsTest
    static void mediumPriorityAddsTwentyFourHours() {
        Datetime startTime = Datetime.newInstance(2026, 1, 1, 9, 0, 0);

        Datetime result = SlaService.calculateDueDate(startTime, 'Medium');

        System.assertEquals(startTime.addHours(24), result, 'Medium priority should add 24 hours');
    }

    @IsTest
    static void lowPriorityAddsFortyEightHours() {
        Datetime startTime = Datetime.newInstance(2026, 1, 1, 9, 0, 0);

        Datetime result = SlaService.calculateDueDate(startTime, 'Low');

        System.assertEquals(startTime.addHours(48), result, 'Low priority should add 48 hours');
    }

    @IsTest
    static void nullPriorityFallsBackToMedium() {
        Datetime startTime = Datetime.newInstance(2026, 1, 1, 9, 0, 0);

        Datetime result = SlaService.calculateDueDate(startTime, null);

        System.assertEquals(startTime.addHours(24), result, 'Null priority should fall back to the Medium rule (24 hours)');
    }

    @IsTest
    static void unknownPriorityFallsBackToMedium() {
        Datetime startTime = Datetime.newInstance(2026, 1, 1, 9, 0, 0);

        Datetime result = SlaService.calculateDueDate(startTime, 'Nonsense');

        System.assertEquals(startTime.addHours(24), result, 'Unknown priority should fall back to the Medium rule (24 hours)');
    }

    @IsTest
    static void blankPriorityFallsBackToMedium() {
        Datetime startTime = Datetime.newInstance(2026, 1, 1, 9, 0, 0);

        Datetime result = SlaService.calculateDueDate(startTime, '');

        System.assertEquals(startTime.addHours(24), result, 'Blank priority should fall back to the Medium rule (24 hours)');
    }
}