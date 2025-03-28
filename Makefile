CONTAINER_NAME=obsidianotes
IMAGE=lscr.io/linuxserver/obsidian:latest
PORT_HTTP=3000
PORT_WS=3001
TIMEZONE=Etc/UTC
PGID=1000
PUID=1000
SHM_SIZE=1gb
NOTES_DIR=$(PWD)/notes
GIT_COMMIT_MESSAGE=Update notes

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@echo "  start    Start the Docker container"
	@echo "  stop     Stop the Docker container and handle Git operations"
	@echo "  clean    Force remove the Docker container (use with caution)"
	@echo "  restart  Restart the container"
	@echo "  status   Display status"

start:
	@echo "Starting Obsidian Docker container..."
	docker run -d \
		--name=$(CONTAINER_NAME) \
		--security-opt seccomp=unconfined \
		-e PUID=$(PUID) \
		-e PGID=$(PGID) \
		-e TZ=$(TIMEZONE) \
		-p $(PORT_HTTP):3000 \
		-p $(PORT_WS):3001 \
		--shm-size="$(SHM_SIZE)" \
		--restart unless-stopped \
		-v $(NOTES_DIR):/config/Obsidian\ Vault \
		$(IMAGE)
	@echo "Obsidian is now running at http://localhost:$(PORT_HTTP)"
	@echo "----> Simply click on \"Quick start\" to get to your files."

stop:
	@echo "Stopping and removing Obsidian Docker container..."
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

	@echo "Committing and pushing changes to GitHub..."
	@read -p "Enter commit message [$(GIT_COMMIT_MESSAGE)]: " commit_message; \
	commit_message=$${commit_message:-$(GIT_COMMIT_MESSAGE)}; \
	git add . && \
		git commit -m "$$commit_message" && \
		git push origin main

clean:
	@echo "Force removing Obsidian Docker container..."
	docker rm -f $(CONTAINER_NAME) || true

restart: stop start

status:
	@docker ps -a | grep $(CONTAINER_NAME) || echo "Container $(CONTAINER_NAME) is not running."

.PHONY: start stop clean restart status
