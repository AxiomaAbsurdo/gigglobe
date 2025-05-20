#!/bin/bash

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======= Kestra Prerequisites Check =======${NC}"

# Check 1: Docker installation
echo -e "\n${YELLOW}Checking Docker installation...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker is installed${NC}"
    docker --version
else
    echo -e "${RED}✗ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check 2: Directory for plugins
echo -e "\n${YELLOW}Checking plugins directory...${NC}"
if [ -d "$(pwd)/plugins" ]; then
    echo -e "${GREEN}✓ Plugins directory exists at $(pwd)/plugins${NC}"
else
    echo -e "${YELLOW}! Plugins directory does not exist. Creating it now...${NC}"
    mkdir -p "$(pwd)/plugins"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Created plugins directory at $(pwd)/plugins${NC}"
    else
        echo -e "${RED}✗ Failed to create plugins directory. Check permissions.${NC}"
        exit 1
    fi
fi

# Check 3: Check port availability
echo -e "\n${YELLOW}Checking if port 8080 is available...${NC}"
if command -v lsof &> /dev/null; then
    PORT_CHECK=$(lsof -i:8080 -sTCP:LISTEN)
    if [ -z "$PORT_CHECK" ]; then
        echo -e "${GREEN}✓ Port 8080 is available${NC}"
    else
        echo -e "${RED}✗ Port 8080 is already in use:${NC}"
        echo "$PORT_CHECK"
        echo -e "${YELLOW}Consider using a different port or stopping the conflicting service.${NC}"
    fi
else
    echo -e "${YELLOW}! Cannot check port availability (lsof not installed)${NC}"
fi

# Check 4: Create application.yml with required repository config
echo -e "\n${YELLOW}Checking application.yml configuration...${NC}"
if [ -f "$(pwd)/application.yml" ]; then
    echo -e "${YELLOW}! Existing application.yml found. Checking for repository configuration...${NC}"
    
    if grep -q "kestra.repository.type" "$(pwd)/application.yml"; then
        echo -e "${GREEN}✓ Repository type is already configured in application.yml${NC}"
    else
        echo -e "${YELLOW}! Repository type not found in existing application.yml${NC}"
        echo -e "${YELLOW}! Will create a backup and add the configuration...${NC}"
        cp "$(pwd)/application.yml" "$(pwd)/application.yml.backup.$(date +%s)"
        echo -e "\n# Added by prerequisites check script\nkestra:\n  repository:\n    type: h2" >> "$(pwd)/application.yml"
        echo -e "${GREEN}✓ Added H2 repository configuration to application.yml${NC}"
    fi
else
    echo -e "${YELLOW}! application.yml not found. Creating minimal configuration...${NC}"
    cat > "$(pwd)/application.yml" << EOL
# Kestra configuration
kestra:
  repository:
    type: h2  # Using H2 database for simplicity (alternatives: mysql, postgres)
  storage:
    type: local
    local:
      base-path: /tmp/kestra_storage
EOL
    echo -e "${GREEN}✓ Created application.yml with H2 repository configuration${NC}"
fi
