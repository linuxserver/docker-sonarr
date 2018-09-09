pipeline {
  agent {
    label 'X86-64-MULTI'
  }
  // Configuraiton for the variables used for this specific repo
  environment {
    BUILD_VERSION_ARG = 'SONARR_VERSION'
    LS_USER = 'linuxserver'
    LS_REPO = 'docker-sonarr'
    DOCKERHUB_IMAGE = 'linuxserver/sonarr'
    DEV_DOCKERHUB_IMAGE = 'lsiodev/sonarr'
    PR_DOCKERHUB_IMAGE = 'lspipepr/sonarr'
    BUILDS_DISCORD = credentials('build_webhook_url')
    GITHUB_TOKEN = credentials('498b4638-2d02-4ce5-832d-8a57d01d97ab')
    DIST_IMAGE = 'ubuntu'
    DIST_TAG = 'xenial'
    DIST_PACKAGES = 'none'
    DIST_REPO = 'http://apt.sonarr.tv/dists/master/main/binary-amd64/Packages'
    DIST_REPO_PACKAGE = 'nzbdrone'
    MULTIARCH='true'
    CI='true'
    CI_WEB='true'
    CI_PORT='8989'
    CI_SSL='false'
    CI_DELAY='60'
    CI_DOCKERENV='TZ=US/Pacific'
    CI_AUTH='user:password'
    CI_WEBPATH=''
  }
  stages {
    // Setup all the basic environment variables needed for the build
    stage("Set ENV Variables base"){
      steps{
        script{
          env.LS_RELEASE = sh(
            script: '''curl -s https://api.github.com/repos/${LS_USER}/${LS_REPO}/releases/latest | jq -r '. | .tag_name' ''',
            returnStdout: true).trim()
          env.LS_RELEASE_NOTES = sh(
            script: '''git log -1 --pretty=%B | sed -E ':a;N;$!ba;s/\\r{0,1}\\n/\\\\n/g' ''',
            returnStdout: true).trim()
          env.GITHUB_DATE = sh(
            script: '''date '+%Y-%m-%dT%H:%M:%S%:z' ''',
            returnStdout: true).trim()
          env.COMMIT_SHA = sh(
            script: '''git rev-parse HEAD''',
            returnStdout: true).trim()
          env.CODE_URL = 'https://github.com/' + env.LS_USER + '/' + env.LS_REPO + '/commit/' + env.GIT_COMMIT
          env.DOCKERHUB_LINK = 'https://hub.docker.com/r/' + env.DOCKERHUB_IMAGE + '/tags/'
          env.PULL_REQUEST = env.CHANGE_ID
        }
        script{
          env.LS_RELEASE_NUMBER = sh(
            script: '''echo ${LS_RELEASE} |sed 's/^.*-ls//g' ''',
            returnStdout: true).trim()
        }
        script{
          env.LS_TAG_NUMBER = sh(
            script: '''#! /bin/bash
                       tagsha=$(git rev-list -n 1 ${LS_RELEASE} 2>/dev/null)
                       if [ "${tagsha}" == "${COMMIT_SHA}" ]; then
                         echo ${LS_RELEASE_NUMBER}
                       elif [ -z "${GIT_COMMIT}" ]; then
                         echo ${LS_RELEASE_NUMBER}
                       else
                         echo $((${LS_RELEASE_NUMBER} + 1))
                       fi''',
            returnStdout: true).trim()
        }
      }
    }
    /* #######################
       Package Version Tagging
       ####################### */
    // If this is an ubuntu base image determine the base package tag to use
    stage("Set Package tag Ubuntu"){
     when {
       environment name: 'DIST_IMAGE', value: 'ubuntu'
       not {environment name: 'DIST_PACKAGES', value: 'none'}
     }
     steps{
       sh '''docker pull ubuntu:${DIST_TAG}'''
       script{
         env.PACKAGE_TAG = sh(
           script: '''docker run --rm ubuntu:${DIST_TAG} sh -c\
                      'apt-get --allow-unauthenticated update -qq >/dev/null 2>&1 &&\
                       apt-cache --no-all-versions show '"${DIST_PACKAGES}"' | md5sum | cut -c1-8' ''',
           returnStdout: true).trim()
       }
     }
    }
    /* ########################
       External Release Tagging
       ######################## */
    // If this is a deb repo release pull the specific version from the packages file
    stage("Set EXT tag deb repo"){
     steps{
       sh '''docker pull ${DIST_IMAGE}:${DIST_TAG}'''
       script{
         env.EXT_RELEASE = sh(
           script: '''curl -sX GET ${DIST_REPO} \
         	|grep -A 6 -m 1 "Package: ${DIST_REPO_PACKAGE}" | awk -F ": " '/Version/{print $2;exit}' ''',
           returnStdout: true).trim()
         env.RELEASE_LINK = env.DIST_REPO
       }
     }
    }
    // If this is a master build use live docker endpoints
    stage("Set ENV live build"){
      when {
        branch "master"
        environment name: 'CHANGE_ID', value: ''
      }
      steps {
        script{
          env.IMAGE = env.DOCKERHUB_IMAGE
          if (env.MULTIARCH == 'true') {
            env.CI_TAGS = 'amd64-' + env.EXT_RELEASE + '-ls' + env.LS_TAG_NUMBER + '|arm32v6-' + env.EXT_RELEASE + '-ls' + env.LS_TAG_NUMBER + '|arm64v8-' + env.EXT_RELEASE + '-ls' + env.LS_TAG_NUMBER
          } else {
            env.CI_TAGS = env.EXT_RELEASE + '-ls' + env.LS_TAG_NUMBER
          }
          env.META_TAG = env.EXT_RELEASE + '-ls' + env.LS_TAG_NUMBER
        }
      }
    }
    // If this is a dev build use dev docker endpoints
    stage("Set ENV dev build"){
      when {
        not {branch "master"}
        environment name: 'CHANGE_ID', value: ''
      }
      steps {
        script{
          env.IMAGE = env.DEV_DOCKERHUB_IMAGE
          if (env.MULTIARCH == 'true') {
            env.CI_TAGS = 'amd64-' + env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-dev-' + env.COMMIT_SHA + '|arm32v6-' + env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-dev-' + env.COMMIT_SHA + '|arm64v8-' + env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-dev-' + env.COMMIT_SHA
          } else {
            env.CI_TAGS = env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-dev-' + env.COMMIT_SHA
          }
          env.META_TAG = env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-dev-' + env.COMMIT_SHA
          env.DOCKERHUB_LINK = 'https://hub.docker.com/r/' + env.DEV_DOCKERHUB_IMAGE + '/tags/'
        }
      }
    }
    // If this is a pull request build use dev docker endpoints
    stage("Set ENV PR build"){
      when {
        not {environment name: 'CHANGE_ID', value: ''}
      }
      steps {
        script{
          env.IMAGE = env.PR_DOCKERHUB_IMAGE
          if (env.MULTIARCH == 'true') {
            env.CI_TAGS = 'amd64-' + env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-pr-' + env.PULL_REQUEST + '|arm32v6-' + env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-pr-' + env.PULL_REQUEST + '|arm64v8-' + env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-pr-' + env.PULL_REQUEST
          } else {
            env.CI_TAGS = env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-pr-' + env.PULL_REQUEST
          }
          env.META_TAG = env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-pr-' + env.PULL_REQUEST
          env.CODE_URL = 'https://github.com/' + env.LS_USER + '/' + env.LS_REPO + '/pull/' + env.PULL_REQUEST
          env.DOCKERHUB_LINK = 'https://hub.docker.com/r/' + env.PR_DOCKERHUB_IMAGE + '/tags/'
        }
      }
    }
    // Use helper container to render a readme from the template if needed
    stage('Update-README') {
      when {
        branch "master"
        environment name: 'CHANGE_ID', value: ''
        expression {
          env.CONTAINER_NAME != null
        }
      }
      steps {
        sh '''#! /bin/bash
              TEMPDIR=$(mktemp -d)
              docker pull linuxserver/doc-builder:latest
              docker run --rm -e CONTAINER_NAME=${CONTAINER_NAME} -v ${TEMPDIR}:/ansible/readme linuxserver/doc-builder:latest
              if [ "$(md5sum ${TEMPDIR}/${CONTAINER_NAME}/README.md | awk '{ print $1 }')" != "$(md5sum README.md | awk '{ print $1 }')" ]; then
                git clone https://github.com/${LS_USER}/${LS_REPO}.git ${TEMPDIR}/${LS_REPO}
                cp ${TEMPDIR}/${CONTAINER_NAME}/README.md ${TEMPDIR}/${LS_REPO}/
                cd ${TEMPDIR}/${LS_REPO}/
                git --git-dir ${TEMPDIR}/${LS_REPO}/.git add README.md
                git --git-dir ${TEMPDIR}/${LS_REPO}/.git commit -m 'Bot Updating README from template'
                git --git-dir ${TEMPDIR}/${LS_REPO}/.git push https://LinuxServer-CI:${GITHUB_TOKEN}@github.com/${LS_USER}/${LS_REPO}.git --all
                echo "true" > /tmp/${COMMIT_SHA}-${BUILD_NUMBER}
              else
                echo "false" > /tmp/${COMMIT_SHA}-${BUILD_NUMBER}
              fi
              rm -Rf ${TEMPDIR}'''
        script{
          env.README_UPDATED = sh(
            script: '''cat /tmp/${COMMIT_SHA}-${BUILD_NUMBER}''',
            returnStdout: true).trim()
        }
      }
    }
    // Exit the build if the Readme was just updated
    stage('README-exit') {
      when {
        branch "master"
        environment name: 'CHANGE_ID', value: ''
        environment name: 'README_UPDATED', value: 'true'
        expression {
          env.CONTAINER_NAME != null
        }
      }
      steps {
        script{
          env.CI_URL = 'README_UPDATE'
          env.RELEASE_LINK = 'README_UPDATE'
          currentBuild.rawBuild.result = Result.ABORTED
          throw new hudson.AbortException('ABORTED_README')
        }
      }
    }
    /* ###############
       Build Container
       ############### */
     // Build Docker container for push to LS Repo
     stage('Build-Single') {
       when {
         environment name: 'MULTIARCH', value: 'false'
       }
       steps {
         sh "docker build --no-cache -t ${IMAGE}:${META_TAG} \
         --build-arg ${BUILD_VERSION_ARG}=${EXT_RELEASE} --build-arg VERSION=\"${META_TAG}\" --build-arg BUILD_DATE=${GITHUB_DATE} ."
       }
     }
     // Build MultiArch Docker containers for push to LS Repo
     stage('Build-Multi') {
       when {
         environment name: 'MULTIARCH', value: 'true'
       }
       parallel {
         stage('Build X86') {
           steps {
             sh "docker build --no-cache -t ${IMAGE}:amd64-${META_TAG} \
             --build-arg ${BUILD_VERSION_ARG}=${EXT_RELEASE} --build-arg VERSION=\"${META_TAG}\" --build-arg BUILD_DATE=${GITHUB_DATE} ."
           }
         }
         stage('Build ARMHF') {
           agent {
             label 'ARMHF'
           }
           steps {
             withCredentials([
               [
                 $class: 'UsernamePasswordMultiBinding',
                 credentialsId: '3f9ba4d5-100d-45b0-a3c4-633fd6061207',
                 usernameVariable: 'DOCKERUSER',
                 passwordVariable: 'DOCKERPASS'
               ]
             ]) {
               echo 'Logging into DockerHub'
               sh '''#! /bin/bash
                  echo $DOCKERPASS | docker login -u $DOCKERUSER --password-stdin
                  '''
               sh "curl https://lsio-ci.ams3.digitaloceanspaces.com/qemu-arm-static -o qemu-arm-static"
               sh "chmod +x qemu-*"
               sh "docker build --no-cache -f Dockerfile.armhf -t ${IMAGE}:arm32v6-${META_TAG} \
                            --build-arg ${BUILD_VERSION_ARG}=${EXT_RELEASE} --build-arg VERSION=\"${META_TAG}\" --build-arg BUILD_DATE=${GITHUB_DATE} ."
               sh "docker tag ${IMAGE}:arm32v6-${META_TAG} lsiodev/buildcache:arm32v6-${COMMIT_SHA}-${BUILD_NUMBER}"
               sh "docker push lsiodev/buildcache:arm32v6-${COMMIT_SHA}-${BUILD_NUMBER}"
             }
           }
         }
         stage('Build ARM64') {
           agent {
             label 'ARM64'
           }
           steps {
             withCredentials([
               [
                 $class: 'UsernamePasswordMultiBinding',
                 credentialsId: '3f9ba4d5-100d-45b0-a3c4-633fd6061207',
                 usernameVariable: 'DOCKERUSER',
                 passwordVariable: 'DOCKERPASS'
               ]
             ]) {
               echo 'Logging into DockerHub'
               sh '''#! /bin/bash
                  echo $DOCKERPASS | docker login -u $DOCKERUSER --password-stdin
                  '''
               sh "curl https://lsio-ci.ams3.digitaloceanspaces.com/qemu-aarch64-static -o qemu-aarch64-static"
               sh "chmod +x qemu-*"
               sh "docker build --no-cache -f Dockerfile.aarch64 -t ${IMAGE}:arm64v8-${META_TAG} \
                            --build-arg ${BUILD_VERSION_ARG}=${EXT_RELEASE} --build-arg VERSION=\"${META_TAG}\" --build-arg BUILD_DATE=${GITHUB_DATE} ."
               sh "docker tag ${IMAGE}:arm64v8-${META_TAG} lsiodev/buildcache:arm64v8-${COMMIT_SHA}-${BUILD_NUMBER}"
               sh "docker push lsiodev/buildcache:arm64v8-${COMMIT_SHA}-${BUILD_NUMBER}"
             }
           }
         }
       }
     }
    /* #######
       Testing
       ####### */
    // Run Container tests
    stage('Test') {
      when {
        environment name: 'CI', value: 'true'
      }
      steps {
        withCredentials([
          string(credentialsId: 'spaces-key', variable: 'DO_KEY'),
          string(credentialsId: 'spaces-secret', variable: 'DO_SECRET')
        ]) {
          sh '''#! /bin/bash
                docker pull lsiodev/ci:latest
                if [ "${MULTIARCH}" == "true" ]; then
                  docker pull lsiodev/buildcache:arm32v6-${COMMIT_SHA}-${BUILD_NUMBER}
                  docker pull lsiodev/buildcache:arm64v8-${COMMIT_SHA}-${BUILD_NUMBER}
                  docker tag lsiodev/buildcache:arm32v6-${COMMIT_SHA}-${BUILD_NUMBER} ${IMAGE}:arm32v6-${META_TAG}
                  docker tag lsiodev/buildcache:arm64v8-${COMMIT_SHA}-${BUILD_NUMBER} ${IMAGE}:arm64v8-${META_TAG}
                fi
                docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -e IMAGE=\"${IMAGE}\" \
                -e DELAY_START=\"${CI_DELAY}\" \
                -e TAGS=\"${CI_TAGS}\" \
                -e META_TAG=\"${META_TAG}\" \
                -e PORT=\"${CI_PORT}\" \
                -e SSL=\"${CI_SSL}\" \
                -e BASE=\"${DIST_IMAGE}\" \
                -e SECRET_KEY=\"${DO_SECRET}\" \
                -e ACCESS_KEY=\"${DO_KEY}\" \
                -e DOCKER_ENV=\"DB_HOST=${TEST_MYSQL_HOST}|DB_DATABASE=bookstack|DB_USERNAME=root|DB_PASSWORD=${TEST_MYSQL_PASSWORD}\" \
                -e WEB_SCREENSHOT=\"${CI_WEB}\" \
                -e WEB_AUTH=\"${CI_AUTH}\" \
                -e WEB_PATH=\"${CI_WEBPATH}\" \
                -e DO_REGION="ams3" \
                -e DO_BUCKET="lsio-ci" \
                -t lsiodev/ci:latest \
                python /ci/ci.py'''
          script{
            env.CI_URL = 'https://lsio-ci.ams3.digitaloceanspaces.com/' + env.IMAGE + '/' + env.META_TAG + '/index.html'
          }
        }
      }
    }
    /* ##################
         Release Logic
       ################## */
    // If this is an amd64 only image only push a single image
    stage('Docker-Push-Single') {
      when {
        environment name: 'MULTIARCH', value: 'false'
      }
      steps {
        withCredentials([
          [
            $class: 'UsernamePasswordMultiBinding',
            credentialsId: '3f9ba4d5-100d-45b0-a3c4-633fd6061207',
            usernameVariable: 'DOCKERUSER',
            passwordVariable: 'DOCKERPASS'
          ]
        ]) {
          echo 'Logging into DockerHub'
          sh '''#! /bin/bash
             echo $DOCKERPASS | docker login -u $DOCKERUSER --password-stdin
             '''
          sh "docker tag ${IMAGE}:${META_TAG} ${IMAGE}:latest"
          sh "docker push ${IMAGE}:latest"
          sh "docker push ${IMAGE}:${META_TAG}"
        }
      }
    }
    // If this is a multi arch release push all images and define the manifest
    stage('Docker-Push-Multi') {
      when {
        environment name: 'MULTIARCH', value: 'true'
      }
      steps {
        withCredentials([
          [
            $class: 'UsernamePasswordMultiBinding',
            credentialsId: '3f9ba4d5-100d-45b0-a3c4-633fd6061207',
            usernameVariable: 'DOCKERUSER',
            passwordVariable: 'DOCKERPASS'
          ]
        ]) {
          sh '''#! /bin/bash
             echo $DOCKERPASS | docker login -u $DOCKERUSER --password-stdin
             '''
          sh '''#! /bin/bash
                if [ "${CI}" == "false" ]; then
                  docker pull lsiodev/buildcache:arm32v6-${COMMIT_SHA}-${BUILD_NUMBER}
                  docker pull lsiodev/buildcache:arm64v8-${COMMIT_SHA}-${BUILD_NUMBER}
                  docker tag lsiodev/buildcache:arm32v6-${COMMIT_SHA}-${BUILD_NUMBER} ${IMAGE}:arm32v6-${META_TAG}
                  docker tag lsiodev/buildcache:arm64v8-${COMMIT_SHA}-${BUILD_NUMBER} ${IMAGE}:arm64v8-${META_TAG}
                fi'''
          sh "docker tag ${IMAGE}:amd64-${META_TAG} ${IMAGE}:amd64-latest"
          sh "docker tag ${IMAGE}:arm32v6-${META_TAG} ${IMAGE}:arm32v6-latest"
          sh "docker tag ${IMAGE}:arm64v8-${META_TAG} ${IMAGE}:arm64v8-latest"
          sh "docker push ${IMAGE}:amd64-${META_TAG}"
          sh "docker push ${IMAGE}:arm32v6-${META_TAG}"
          sh "docker push ${IMAGE}:arm64v8-${META_TAG}"
          sh "docker push ${IMAGE}:amd64-latest"
          sh "docker push ${IMAGE}:arm32v6-latest"
          sh "docker push ${IMAGE}:arm64v8-latest"
          sh "docker manifest push --purge ${IMAGE}:latest || :"
          sh "docker manifest create ${IMAGE}:latest ${IMAGE}:amd64-latest ${IMAGE}:arm32v6-latest ${IMAGE}:arm64v8-latest"
          sh "docker manifest annotate ${IMAGE}:latest ${IMAGE}:arm32v6-latest --os linux --arch arm"
          sh "docker manifest annotate ${IMAGE}:latest ${IMAGE}:arm64v8-latest --os linux --arch arm64 --variant armv8"
          sh "docker manifest push --purge ${IMAGE}:${EXT_RELEASE}-ls${LS_TAG_NUMBER} || :"
          sh "docker manifest create ${IMAGE}:${META_TAG} ${IMAGE}:amd64-${META_TAG} ${IMAGE}:arm32v6-${META_TAG} ${IMAGE}:arm64v8-${META_TAG}"
          sh "docker manifest annotate ${IMAGE}:${META_TAG} ${IMAGE}:arm32v6-${META_TAG} --os linux --arch arm"
          sh "docker manifest annotate ${IMAGE}:${META_TAG} ${IMAGE}:arm64v8-${META_TAG} --os linux --arch arm64 --variant armv8"
          sh "docker manifest push --purge ${IMAGE}:latest"
          sh "docker manifest push --purge ${IMAGE}:${META_TAG}"
        }
      }
    }
    // If this is a public release tag it in the LS Github and push a changelog from external repo and our internal one
    stage('Github-Tag-Push-Release') {
      when {
        branch "master"
        expression {
          env.LS_RELEASE != env.EXT_RELEASE + '-pkg-' + env.PACKAGE_TAG + '-ls' + env.LS_TAG_NUMBER
        }
        environment name: 'CHANGE_ID', value: ''
      }
      steps {
        echo "Pushing New tag for current commit ${EXT_RELEASE}-pkg-${PACKAGE_TAG}-ls${LS_TAG_NUMBER}"
        sh '''curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST https://api.github.com/repos/${LS_USER}/${LS_REPO}/git/tags \
        -d '{"tag":"'${EXT_RELEASE}'-pkg-'${PACKAGE_TAG}'-ls'${LS_TAG_NUMBER}'",\
             "object": "'${COMMIT_SHA}'",\
             "message": "Tagging Release '${EXT_RELEASE}'-pkg-'${PACKAGE_TAG}'-ls'${LS_TAG_NUMBER}' to master",\
             "type": "commit",\
             "tagger": {"name": "LinuxServer Jenkins","email": "jenkins@linuxserver.io","date": "'${GITHUB_DATE}'"}}' '''
        echo "Pushing New release for Tag"
        sh '''#! /bin/bash
              echo "Updating ${DIST_REPO_PACKAGE} to ${EXT_RELEASE}" > releasebody.json
              echo '{"tag_name":"'${EXT_RELEASE}'-pkg-'${PACKAGE_TAG}'-ls'${LS_TAG_NUMBER}'",\
                     "target_commitish": "master",\
                     "name": "'${EXT_RELEASE}'-pkg-'${PACKAGE_TAG}'-ls'${LS_TAG_NUMBER}'",\
                     "body": "**LinuxServer Changes:**\\n\\n'${LS_RELEASE_NOTES}'\\n**Repo Changes:**\\n\\n' > start
              printf '","draft": false,"prerelease": false}' >> releasebody.json
              paste -d'\\0' start releasebody.json > releasebody.json.done
              curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST https://api.github.com/repos/${LS_USER}/${LS_REPO}/releases -d @releasebody.json.done'''
      }
    }
    // Use helper container to sync the current README on master to the dockerhub endpoint
    stage('Sync-README') {
      when {
        environment name: 'CHANGE_ID', value: ''
      }
      steps {
        withCredentials([
          [
            $class: 'UsernamePasswordMultiBinding',
            credentialsId: '3f9ba4d5-100d-45b0-a3c4-633fd6061207',
            usernameVariable: 'DOCKERUSER',
            passwordVariable: 'DOCKERPASS'
          ]
        ]) {
          sh '''#! /bin/bash
                docker pull lsiodev/readme-sync
                docker run --rm=true \
                  -e DOCKERHUB_USERNAME=$DOCKERUSER \
                  -e DOCKERHUB_PASSWORD=$DOCKERPASS \
                  -e GIT_REPOSITORY=${LS_USER}/${LS_REPO} \
                  -e DOCKER_REPOSITORY=${DOCKERHUB_IMAGE} \
                  -e GIT_BRANCH=master \
                  lsiodev/readme-sync bash -c 'node sync' '''
        }
      }
    }
  }
  /* ######################
     Send status to Discord
     ###################### */
  post {
    success {
      sh ''' curl -X POST --data '{"avatar_url": "https://wiki.jenkins-ci.org/download/attachments/2916393/headshot.png","embeds": [{"color": 1681177,\
             "description": "**Build:**  '${BUILD_NUMBER}'\\n**CI Results:**  '${CI_URL}'\\n**Status:**  Success\\n**Job:** '${RUN_DISPLAY_URL}'\\n**Change:** '${CODE_URL}'\\n**External Release:**: '${RELEASE_LINK}'\\n**DockerHub:** '${DOCKERHUB_LINK}'\\n"}],\
             "username": "Jenkins"}' ${BUILDS_DISCORD} '''
    }
    failure {
      sh ''' curl -X POST --data '{"avatar_url": "https://wiki.jenkins-ci.org/download/attachments/2916393/headshot.png","embeds": [{"color": 16711680,\
             "description": "**Build:**  '${BUILD_NUMBER}'\\n**CI Results:**  '${CI_URL}'\\n**Status:**  failure\\n**Job:** '${RUN_DISPLAY_URL}'\\n**Change:** '${CODE_URL}'\\n**External Release:**: '${RELEASE_LINK}'\\n**DockerHub:** '${DOCKERHUB_LINK}'\\n"}],\
             "username": "Jenkins"}' ${BUILDS_DISCORD} '''
    }
  }
}
