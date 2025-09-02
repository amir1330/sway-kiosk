chrome.runtime.onInstalled.addListener(() => {
  console.log('On-Screen Keyboard RU/EN extension installed');
});

// Listen for messages from content script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'KEYBOARD_STATE') {
    // Handle keyboard state changes if needed
    sendResponse({ success: true });
  }
});
