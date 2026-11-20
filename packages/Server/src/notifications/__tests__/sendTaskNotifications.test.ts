import { describe, it, expect, beforeEach, vi } from 'vitest';

const { config, sendNotification, logError } = vi.hoisted(() => ({
  config: vi.fn(),
  sendNotification: vi.fn(),
  logError: vi.fn(),
}));

vi.mock('@memberjunction/core', () => ({
  LogError: logError,
  UserInfo: class {},
}));
vi.mock('@memberjunction/notifications', () => ({
  NotificationEngine: { Instance: { Config: config, SendNotification: sendNotification } },
}));

import { sendTaskNotifications, TASK_COMPLETED_NOTIFICATION_TYPE, type TaskNotification } from '../sendTaskNotifications.js';
import type { UserInfo } from '@memberjunction/core';

const contextUser = { ID: 'user-ctx' } as UserInfo;

const notification: TaskNotification = {
  TypeName: TASK_COMPLETED_NOTIFICATION_TYPE,
  Title: 'Task Completed: Approve discount',
  Message: '"Approve discount" has been marked as completed.',
  TemplateData: { taskName: 'Approve discount' },
};

beforeEach(() => {
  vi.clearAllMocks();
  config.mockResolvedValue(undefined);
  sendNotification.mockResolvedValue({ success: true, deliveryChannels: { inApp: true, email: true, sms: false } });
});

describe('sendTaskNotifications', () => {
  it('sends one typed notification per user through the engine', async () => {
    const sent = await sendTaskNotifications(['user-1', 'user-2'], notification, contextUser);

    expect(sent).toBe(2);
    expect(config).toHaveBeenCalledWith(false, contextUser);
    expect(sendNotification).toHaveBeenCalledTimes(2);
    expect(sendNotification).toHaveBeenCalledWith(
      {
        userId: 'user-1',
        typeNameOrId: 'Task Completed',
        title: notification.Title,
        message: notification.Message,
        templateData: notification.TemplateData,
      },
      contextUser,
    );
  });

  it('does nothing for an empty recipient list', async () => {
    const sent = await sendTaskNotifications([], notification, contextUser);

    expect(sent).toBe(0);
    expect(config).not.toHaveBeenCalled();
    expect(sendNotification).not.toHaveBeenCalled();
  });

  it('logs and counts out a send the engine reports as failed', async () => {
    sendNotification
      .mockResolvedValueOnce({ success: false, errors: ['Notification type not found: Task Completed'] })
      .mockResolvedValueOnce({ success: true });

    const sent = await sendTaskNotifications(['user-1', 'user-2'], notification, contextUser);

    expect(sent).toBe(1);
    expect(logError).toHaveBeenCalledOnce();
    expect(logError.mock.calls[0][0]).toContain('Notification type not found');
  });

  it('logs a send that throws and does not rethrow', async () => {
    sendNotification.mockRejectedValue(new Error('engine not loaded'));

    await expect(sendTaskNotifications(['user-1'], notification, contextUser)).resolves.toBe(0);
    expect(logError.mock.calls[0][0]).toContain('engine not loaded');
  });

  it('logs and sends nothing when the engine cannot be configured', async () => {
    config.mockRejectedValue(new Error('no provider'));

    await expect(sendTaskNotifications(['user-1'], notification, contextUser)).resolves.toBe(0);
    expect(sendNotification).not.toHaveBeenCalled();
    expect(logError.mock.calls[0][0]).toContain('no provider');
  });
});
