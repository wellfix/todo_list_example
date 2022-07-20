<?php

namespace App\Controller;

use App\Entity\ToDoList;
use App\Form\ToDoListForm;
use App\Repository\ToDoListRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class HomePageController extends AbstractController
{
    #[Route('', name: "home_page", methods: ['GET'])]
    function homePage(ToDoListRepository $doListRepository): Response
    {
        $list = $doListRepository->findAll();
        $title = "I am the title of this page";
        return $this->render('home.page.html.twig', ['list' => $list, 'title' => $title]);
    }

    #[Route('/add', name: "add_task", methods: ['GET', 'POST'])]
    function addTask(Request $request, EntityManagerInterface $entityManager): RedirectResponse|Response
    {

        $task = new ToDoList();

        $form = $this->createForm(ToDoListForm::class, $task);

        $form->handleRequest($request);

        if($form->isSubmitted() && $form->isValid()) {
            $task = $form->getData();
            $entityManager->persist($task);
            $entityManager->flush();

            return $this->redirectToRoute('home_page');
        }

        return $this->renderForm('form.page.html.twig', ['form' => $form]);
    }
}