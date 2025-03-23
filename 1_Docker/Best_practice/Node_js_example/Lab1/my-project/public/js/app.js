document.addEventListener('DOMContentLoaded', () => {
    const messageDiv = document.getElementById('message');
    const fetchButton = document.getElementById('fetchButton');

    // Function to fetch message from API
    async function fetchMessage() {
        try {
            messageDiv.textContent = 'Loading...';
            const response = await fetch('/api/hello');
            const data = await response.json();
            messageDiv.textContent = data.message;
        } catch (error) {
            messageDiv.textContent = 'Error loading message!';
            console.error('Error fetching message:', error);
        }
    }

    // Add event listener to button
    fetchButton.addEventListener('click', fetchMessage);

    // Fetch message on page load
    fetchMessage();
});